using System;
using System.Text;
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
using PregnancyBattle.Application.Services;
using PregnancyBattle.Application.Services.Implementations;
using PregnancyBattle.Application.Validators;
using PregnancyBattle.Domain.Repositories;
using PregnancyBattle.Domain.Services;
using PregnancyBattle.Infrastructure.Data.Contexts;
using PregnancyBattle.Infrastructure.Data.Repositories;
using PregnancyBattle.Infrastructure.Services.Email;
using PregnancyBattle.Infrastructure.Services.Supabase;

var builder = WebApplication.CreateBuilder(args);

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
builder.Services.AddAutoMapper(typeof(MappingProfile));

// 添加FluentValidation
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserValidator>();

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
// 添加其他服务...

// 添加邮件服务
builder.Services.AddSingleton<IEmailService, EmailService>();

// 添加Supabase服务
// builder.Services.AddSingleton<ISupabaseService, SupabaseService>();

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

app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();