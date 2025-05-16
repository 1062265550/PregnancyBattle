using System;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace PregnancyBattle.Api.Utils
{
    /// <summary>
    /// 自定义日期时间转换器，确保日期以ISO8601格式序列化
    /// </summary>
    public class JsonDateTimeConverter : JsonConverter<DateTime>
    {
        public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            // 尝试解析日期时间字符串
            if (reader.TokenType == JsonTokenType.String)
            {
                string dateString = reader.GetString();
                if (DateTime.TryParse(dateString, out DateTime date))
                {
                    return date;
                }
            }
            
            return DateTime.MinValue;
        }

        public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
        {
            // 使用ISO8601格式序列化日期时间
            writer.WriteStringValue(value.ToUniversalTime().ToString("o"));
        }
    }

    /// <summary>
    /// 自定义可空日期时间转换器，确保可空日期以ISO8601格式序列化
    /// </summary>
    public class JsonNullableDateTimeConverter : JsonConverter<DateTime?>
    {
        public override DateTime? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            if (reader.TokenType == JsonTokenType.Null)
            {
                return null;
            }
            
            // 尝试解析日期时间字符串
            if (reader.TokenType == JsonTokenType.String)
            {
                string dateString = reader.GetString();
                if (DateTime.TryParse(dateString, out DateTime date))
                {
                    return date;
                }
            }
            
            return null;
        }

        public override void Write(Utf8JsonWriter writer, DateTime? value, JsonSerializerOptions options)
        {
            if (value.HasValue)
            {
                // 使用ISO8601格式序列化日期时间
                writer.WriteStringValue(value.Value.ToUniversalTime().ToString("o"));
            }
            else
            {
                writer.WriteNullValue();
            }
        }
    }
}
