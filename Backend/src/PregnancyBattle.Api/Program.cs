using System;
using System.Text;
using AutoMapper;
using Dapper;
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Npgsql;
using PregnancyBattle.Api.Middlewares;
using PregnancyBattle.Api.Utils;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Mappings;
using PregnancyBattle.Application.Services.Interfaces;
using PregnancyBattle.Application.Services.Implementations;
using PregnancyBattle.Application.Validators;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using PregnancyBattle.Domain.Services;
using PregnancyBattle.Infrastructure.Data.Contexts;
using PregnancyBattle.Infrastructure.Data.Repositories;
using PregnancyBattle.Infrastructure.Repositories;
using PregnancyBattle.Infrastructure.Services.Email;

using PregnancyBattle.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// 配置Dapper字段映射
ConfigureDapperMappings();

// 添加服务到容器
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // 配置日期格式为 ISO8601 标准
        options.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
        // 添加ISO8601日期格式转换器
        options.JsonSerializerOptions.Converters.Add(new JsonDateTimeConverter());
        options.JsonSerializerOptions.Converters.Add(new JsonNullableDateTimeConverter());
        // 将属性名策略更改为 camelCase
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

// 添加Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "孕期大作战 API", Version = "v1" });

    // 添加JWT认证
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// 添加JWT认证
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "DefaultKeyForDevelopment"))
        };
    });

// 添加AutoMapper
builder.Services.AddAutoMapper(typeof(MappingProfile), typeof(HealthProfileMappingProfile), typeof(DiaryMappingProfile));

// 添加FluentValidation
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<CreateHealthProfileDtoValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<CreateDiaryDtoValidator>();

// 配置日志
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// 配置 Npgsql 详细日志
builder.Logging.AddFilter("Npgsql", LogLevel.Debug);
builder.Logging.AddFilter("Microsoft.EntityFrameworkCore.Database.Command", LogLevel.Information);
NpgsqlLoggingConfiguration.InitializeLogging(builder.Services.BuildServiceProvider().GetRequiredService<ILoggerFactory>());

// 添加数据库上下文
builder.Services.AddSingleton<IDbContext>(provider =>
{
    var configuration = provider.GetRequiredService<IConfiguration>();
    var logger = provider.GetRequiredService<ILogger<PostgresDbContext>>();
    return new PostgresDbContext(configuration, logger);
});

// 添加仓储
builder.Services.AddScoped<IUserRepository>(provider =>
{
    var dbContext = provider.GetRequiredService<IDbContext>();
    var logger = provider.GetRequiredService<ILogger<UserRepository>>();
    return new UserRepository(dbContext, logger);
});
// 添加孕期信息仓储
builder.Services.AddScoped<IPregnancyInfoRepository, PregnancyInfoRepository>();
// 添加健康档案仓储
builder.Services.AddScoped<IHealthProfileRepository, HealthProfileRepository>();
// 添加日记仓储
builder.Services.AddScoped<IDiaryRepository>(provider =>
{
    var configuration = provider.GetRequiredService<IConfiguration>();
    var connectionString = configuration.GetConnectionString("DefaultConnection");
    return new DiaryRepository(connectionString);
});

// 添加其他仓储...

// 添加服务
builder.Services.AddScoped<IUserService>(provider =>
{
    var userRepository = provider.GetRequiredService<IUserRepository>();
    var configuration = provider.GetRequiredService<IConfiguration>();
    var logger = provider.GetRequiredService<ILogger<UserService>>();
    var emailService = provider.GetRequiredService<IEmailService>();
    return new UserService(userRepository, configuration, logger, emailService);
});
// 添加孕期信息服务
builder.Services.AddScoped<IPregnancyInfoService, PregnancyInfoService>();
// 添加健康档案服务
builder.Services.AddScoped<IHealthProfileService, HealthProfileService>();
// 添加健康风险评估仓储
builder.Services.AddScoped<IHealthRiskAssessmentRepository, HealthRiskAssessmentRepository>();
// 添加日记服务
builder.Services.AddScoped<IDiaryService>(provider =>
{
    var diaryRepository = provider.GetRequiredService<IDiaryRepository>();
    var pregnancyInfoRepository = provider.GetRequiredService<IPregnancyInfoRepository>();
    var fileStorageService = provider.GetRequiredService<IFileStorageService>();
    var mapper = provider.GetRequiredService<IMapper>();
    var logger = provider.GetRequiredService<ILogger<DiaryService>>();
    return new DiaryService(diaryRepository, pregnancyInfoRepository, fileStorageService, mapper, logger);
});

// 添加其他服务...

// 添加邮件服务
builder.Services.AddSingleton<IEmailService, EmailService>();

// 添加DeepSeek AI服务
builder.Services.AddHttpClient<IDeepSeekService, PregnancyBattle.Infrastructure.Services.DeepSeekService>(client =>
{
    client.Timeout = TimeSpan.FromSeconds(120); // 设置120秒超时，给AI处理留足时间
});

// 添加文件存储服务
builder.Services.AddScoped<IFileStorageService, PregnancyBattle.Infrastructure.Services.FileStorage.TencentCosStorageService>();



// 添加CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader();
    });
});

var app = builder.Build();

// 配置HTTP请求管道
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// 添加全局异常处理中间件
app.UseGlobalExceptionHandling();

// 只在生产环境启用HTTPS重定向
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("AllowAll");

// 添加静态文件服务（用于本地文件存储）
var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads");
if (!Directory.Exists(uploadsPath))
{
    Directory.CreateDirectory(uploadsPath);
}
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(uploadsPath),
    RequestPath = "/uploads"
});

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();

// 配置Dapper字段映射
static void ConfigureDapperMappings()
{
    // 配置HealthProfile实体的字段映射
    SqlMapper.SetTypeMap(typeof(HealthProfile), new CustomPropertyTypeMap(
        typeof(HealthProfile),
        (type, columnName) =>
        {
            return columnName.ToLower() switch
            {
                "id" => type.GetProperty("Id"),
                "user_id" => type.GetProperty("UserId"),
                "height" => type.GetProperty("Height"),
                "pre_pregnancy_weight" => type.GetProperty("PrePregnancyWeight"),
                "current_weight" => type.GetProperty("CurrentWeight"),
                "blood_type" => type.GetProperty("BloodType"),
                "age" => type.GetProperty("Age"),
                "medical_history" => type.GetProperty("MedicalHistory"),
                "family_history" => type.GetProperty("FamilyHistory"),
                "allergies_history" => type.GetProperty("AllergiesHistory"),
                "obstetric_history" => type.GetProperty("ObstetricHistory"),
                "is_smoking" => type.GetProperty("IsSmoking"),
                "is_drinking" => type.GetProperty("IsDrinking"),
                "created_at" => type.GetProperty("CreatedAt"),
                "updated_at" => type.GetProperty("UpdatedAt"),
                _ => null
            };
        }
    ));

    // 配置HealthRiskAssessment实体的字段映射
    SqlMapper.SetTypeMap(typeof(HealthRiskAssessment), new CustomPropertyTypeMap(
        typeof(HealthRiskAssessment),
        (type, columnName) =>
        {
            return columnName.ToLower() switch
            {
                "id" => type.GetProperty("Id"),
                "user_id" => type.GetProperty("UserId"),
                "health_profile_id" => type.GetProperty("HealthProfileId"),
                "bmi_category" => type.GetProperty("BmiCategory"),
                "bmi_risk" => type.GetProperty("BmiRisk"),
                "age_risk" => type.GetProperty("AgeRisk"),
                "ai_analysis" => type.GetProperty("AiAnalysisJson"),
                "personalized_recommendations" => type.GetProperty("PersonalizedRecommendationsJson"),
                "is_ai_enhanced" => type.GetProperty("IsAiEnhanced"),
                "health_data_hash" => type.GetProperty("HealthDataHash"),
                "created_at" => type.GetProperty("CreatedAt"),
                "updated_at" => type.GetProperty("UpdatedAt"),
                _ => type.GetProperty(columnName)
            };
        }));

    // 配置WeightLog实体的字段映射
    SqlMapper.SetTypeMap(typeof(WeightLog), new CustomPropertyTypeMap(
        typeof(WeightLog),
        (type, columnName) =>
        {
            return columnName.ToLower() switch
            {
                "id" => type.GetProperty("Id"),
                "user_id" => type.GetProperty("UserId"),
                "record_date" => type.GetProperty("Date"),
                "weight" => type.GetProperty("Weight"),
                "pregnancy_week" => type.GetProperty("PregnancyWeek"),
                "pregnancy_day" => type.GetProperty("PregnancyDay"),
                "note" => type.GetProperty("Note"),
                "created_at" => type.GetProperty("CreatedAt"),
                "updated_at" => type.GetProperty("UpdatedAt"),
                _ => type.GetProperty(columnName)
            };
        }));

    // 配置Diary实体的字段映射
    SqlMapper.SetTypeMap(typeof(Diary), new CustomPropertyTypeMap(
        typeof(Diary),
        (type, columnName) =>
        {
            return columnName.ToLower() switch
            {
                "id" => type.GetProperty("Id"),
                "user_id" => type.GetProperty("UserId"),
                "title" => type.GetProperty("Title"),
                "content" => type.GetProperty("Content"),
                "mood" => type.GetProperty("Mood"),
                "diary_date" => type.GetProperty("DiaryDate"),
                "pregnancy_week" => type.GetProperty("PregnancyWeek"),
                "pregnancy_day" => type.GetProperty("PregnancyDay"),
                "created_at" => type.GetProperty("CreatedAt"),
                "updated_at" => type.GetProperty("UpdatedAt"),
                _ => type.GetProperty(columnName)
            };
        }));

    // 配置DiaryTag实体的字段映射
    SqlMapper.SetTypeMap(typeof(DiaryTag), new CustomPropertyTypeMap(
        typeof(DiaryTag),
        (type, columnName) =>
        {
            return columnName.ToLower() switch
            {
                "id" => type.GetProperty("Id"),
                "diary_id" => type.GetProperty("DiaryId"),
                "name" => type.GetProperty("Name"),
                "created_at" => type.GetProperty("CreatedAt"),
                "updated_at" => type.GetProperty("UpdatedAt"),
                "tagid" => type.GetProperty("Id"),
                "tagname" => type.GetProperty("Name"),
                "tagcreatedat" => type.GetProperty("CreatedAt"),
                "tagupdatedat" => type.GetProperty("UpdatedAt"),
                _ => type.GetProperty(columnName)
            };
        }));

    // 配置DiaryMedia实体的字段映射
    SqlMapper.SetTypeMap(typeof(DiaryMedia), new CustomPropertyTypeMap(
        typeof(DiaryMedia),
        (type, columnName) =>
        {
            return columnName.ToLower() switch
            {
                "id" => type.GetProperty("Id"),
                "diary_id" => type.GetProperty("DiaryId"),
                "media_type" => type.GetProperty("MediaType"),
                "media_url" => type.GetProperty("MediaUrl"),
                "description" => type.GetProperty("Description"),
                "created_at" => type.GetProperty("CreatedAt"),
                "mediaid" => type.GetProperty("Id"),
                "mediatype" => type.GetProperty("MediaType"),
                "mediaurl" => type.GetProperty("MediaUrl"),
                "mediadescription" => type.GetProperty("Description"),
                "mediacreatedat" => type.GetProperty("CreatedAt"),
                _ => type.GetProperty(columnName)
            };
        }));


}