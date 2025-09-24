# Deployment Guide

## SendGrid Configuration

### Required Environment Variables

Set these environment variables in your production environment:

```bash
# SendGrid API Key (get from SendGrid dashboard)
SENDGRID_API_KEY=your_sendgrid_api_key_here

# Your domain for email links
MAILER_HOST=your-domain.com
MAILER_DOMAIN=your-domain.com

# Rails configuration
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_base_here
```

### SendGrid Setup Steps

1. **Create SendGrid Account**
   - Go to [SendGrid](https://sendgrid.com/)
   - Sign up for a free account (100 emails/day free)

2. **Generate API Key**
   - Go to Settings > API Keys
   - Create a new API Key
   - Give it "Mail Send" permissions
   - Copy the API key

3. **Verify Sender Identity**
   - Go to Settings > Sender Authentication
   - Verify a single sender email or your domain
   - This is required to send emails

4. **Set Environment Variables**
   - Add the environment variables to your hosting platform
   - For Heroku: `heroku config:set SENDGRID_API_KEY=your_key`
   - For Railway: Add in the dashboard
   - For Render: Add in the environment section

### Testing Email in Production

1. **Check Logs**
   ```bash
   # View Rails logs for email delivery
   heroku logs --tail
   ```

2. **Test Magic Link**
   - Try logging in with a valid email
   - Check if the magic link email is received
   - Check SendGrid activity dashboard

3. **SendGrid Dashboard**
   - Monitor email delivery in SendGrid dashboard
   - Check for any delivery issues or bounces

### Troubleshooting

**Common Issues:**

1. **"Invalid API Key"**
   - Verify the API key is correct
   - Ensure it has "Mail Send" permissions

2. **"Sender not verified"**
   - Verify your sender email in SendGrid
   - Use a verified sender email

3. **"Domain not verified"**
   - Complete domain verification in SendGrid
   - Add required DNS records

4. **Emails not received**
   - Check spam folder
   - Verify recipient email is valid
   - Check SendGrid activity logs

### Security Notes

- Never commit API keys to version control
- Use environment variables for all sensitive data
- Rotate API keys regularly
- Monitor SendGrid usage and costs
