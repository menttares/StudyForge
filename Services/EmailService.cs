using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Options;
using StudyForge.Models;
namespace StudyForge.Services;


public class EmailService : IEmailService
{
    private readonly SmtpSettings _smtpSettings;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IOptions<SmtpSettings> smtpSettings, ILogger<EmailService> logger)
    {
        _smtpSettings = smtpSettings.Value;
        _logger = logger;
    }

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        try
        {
            var fromAddress = new MailAddress(_smtpSettings.UserName);
            var toAddress = new MailAddress(to);
            var mailMessage = new MailMessage(fromAddress, toAddress)
            {
                Subject = subject,
                Body = body,
                IsBodyHtml = false
            };

            using (var smtpClient = new SmtpClient(_smtpSettings.Host, _smtpSettings.Port)
            {
                Credentials = new NetworkCredential(_smtpSettings.UserName, _smtpSettings.Password),
                EnableSsl = _smtpSettings.EnableSsl
            })
            {
                await smtpClient.SendMailAsync(mailMessage);
                _logger.LogInformation("Сообщение успешно отправлено.");
            }
        }
        catch (FormatException)
        {
            _logger.LogError("Неверный формат электронной почты.");
            throw new ArgumentException("Invalid email format.");
        }
        catch (ArgumentException)
        {
            _logger.LogError("Адрес электронной почты не должен быть пустым.");
            throw;
        }
        catch (SmtpException ex)
        {
            _logger.LogError($"Ошибка при отправке сообщения: {ex.Message}");
            throw new InvalidOperationException("Failed to send email.");
        }
        catch (Exception ex)
        {
            _logger.LogError($"Произошла ошибка: {ex.Message}");
            throw;
        }
    }
}