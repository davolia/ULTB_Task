# Task 1: Research and Setup a Mail Server

## Note
All deployments are for Rocky Linux 9
Please change the variables' values in the **ansible/variables.yml** file and create an .env file containing MYSQL_ROOT_PASSWORD and POSTMASTER_PASSWORD

## Steps
1. Set up Git:
   ```bash
   git init
   git config --global user.name "NAME.SURNAME"
   git config --global user.email "EMAIL"
   git remote add origin git@github.com:davolia/ULTB_Task.git
   ```
2. Set up Ansible:
   ```bash
   dnf install epel-release -y
   dnf install ansible -y
   mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.org
   ansible-config init --disabled > /etc/ansible/ansible.cfg
   echo "127.0.0.1" >> /etc/ansible/hosts.conf
   echo -e "\n[target_servers]" >> /etc/ansible/hosts.conf
   echo "127.0.0.1" >> /etc/ansible/hosts.conf
   ```
3. Set up DNS records:
   ```bash
   A record
   mail    IPADDRESS    not proxied
   @       IPADDRESS    proxied

   MX record
   MX      DOMAINNAME

   SPF record
   TXT    v=spf1 mx a ip4:IPADDRESS -all

   DKIM record
   TXT    dkim._domainkey    "v=DKIM1; p=KEY"

   DMARC record
   TXT    _dmarc    v=DMARC1; p=quarantine; rua=mailto:EMAILADDRESS; ruf=mailto:EMAILADDRESS; pct=100
   ```
4. Run Ansible:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/main.yml
   ```


# Task 2:  Diagnosing DNS Issues

broken.lanycrost.net has the following issues

1. No A record
2. No MX record
3. The SPF record is still pointed to AWS SES service ("v=spf1 include:mail.zendesk.com include:amazonses.com -all")
4. No DKIM record
5. No DMARC record

To fix the problems, we can add these records

1. Add A record For instance ***mail.example.com*** (Not proxied)
2. Add MX record and point to ***mail.example.com***
3. Add SPF record ***v=spf1 mx a ip4:IPADDRESS -all***
4. Add DKIM record ***TXT    dkim._domainkey    "v=DKIM1; p=KEY"***
5. Add DMARC record ***TXT    _dmarc    v=DMARC1; p=quarantine; rua=mailto:EMAILADDRESS; ruf=mailto:EMAILADDRESS; pct=100***
6. Check IP Reputation on services like ***MXToolbox***
7. Monitor and improve deliverability on services like ***SendGrid***



# Task 3: Write a Bash Script to Monitor Mail Server Health and Send Alerts

## Steps

### Create a Telegram Bot and Get the Bot Token:

1. **Open Telegram:**
   - Download and install the Telegram app on your mobile device or use the [Telegram Web](https://web.telegram.org/) version.
2. **Search for BotFather:**
   - In the Telegram app, search for the user `@BotFather` and start a chat with it.
3. **Create a New Bot:**
   - Type `/newbot` and send the message.
   - BotFather will prompt you to choose a name for your bot. Provide a name that describes your bot.
4. **Set a Username:**
   - After naming your bot, you will be prompted to set a username. The username must end with `bot` (e.g., `MySampleBot`).
5. **Receive Your Bot Token:**
   - Once the bot is created, BotFather will send you a message containing the API token. This token is used to authenticate your bot with the Telegram API.
   - **Note:** Keep this token secure and do not share it with others.
6. **Test Your Bot:**
   - Find your bot in the Telegram search and send a message to it. You should receive a response based on how you have configured it.
  

### Find Your Chat ID for Telegram Bot Notifications

7. Start a Chat with Your Bot
- Open the Telegram app.
- Search for the bot you created by its username (e.g., `@iredmail_monitor_bot`).
- Start a conversation with the bot by clicking the "Start" button.
8. Send a Test Message
- Type and send any message to your bot, such as "Test".
9. Retrieve the Chat ID
- Open a web browser and use the following URL format to access Telegram’s API. Make sure to replace `BOT_TOKEN` with the token you received from BotFather: (https://api.telegram.org/bot<BOT_TOKEN>/getUpdates)
10. Get Your Chat ID
- When you open the URL, you will see a JSON output. Look for the `"chat"` section, which will contain an `id` field:
- Copy the ID value from the chat section. This number is your Chat ID (in the example above, it is 987654321).
  
## Note 
**Replace the TELEGRAM_TOKEN and TELEGRAM_CHAT_ID variable's values with your own Token and Chat ID**

### Run an Ansible playbook to run a script and add to Crontab

``` bash
ansible-playbook -i ansible/inventory.ini ansible/script.yml
```
 
