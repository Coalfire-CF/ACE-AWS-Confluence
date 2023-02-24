#!/usr/bin/env bash
set \
  -o nounset \
  -o pipefail \
  -o errexit

echo "===== Downloading Confluence ====="
wget -O ~/confluence.bin ${confluence_dl_url}

# Creating Confluence Varfile
cat <<\EOF >> ~/confluence.varfile
app.confHome=/var/atlassian/application-data/confluence
app.install.service$Boolean=true
existingInstallationDir=/usr/local/Confluence
launch.application$Boolean=false
portChoice=default
sys.adminRights$Boolean=true
sys.confirmedUpdateInstallationString=false
sys.installationDir=/opt/atlassian/confluence
sys.languageId=en
EOF

# Modify Confluence Permissions
chmod +x ~/confluence.bin

# Start Confluence Install
~/confluence.bin -q -varfile ~/confluence.varfile
# /opt/atlassian/confluence/bin/startup.sh

#Creating confluence Service
tee -a /lib/systemd/system/confluence.service << EOF
[Unit] 
Description=Atlassian confluence
After=network.target
[Service] 
Type=forking
User=confluence
LimitNOFILE=20000
PIDFile=/opt/atlassian/confluence/work/catalina.pid
ExecStart=/opt/atlassian/confluence/bin/start-confluence.sh
ExecStop=/opt/atlassian/confluence/bin/stop-confluence.sh
[Install] 
WantedBy=multi-user.target 
EOF

# Change Confluence Service File Permission
chmod 644 /lib/systemd/system/confluence.service

# Cleaning up Confluence Files
rm -f ~/confluence.bin
rm -f ~/confluence.varfile

# # Enable and Start Confluence Service
systemctl daemon-reload
systemctl enable confluence.service
systemctl start confluence.service

# #import CA into keystore 
aws secretsmanager get-secret-value --secret-id "/production/mgmt/ca/rootca/confluence_cert" --region ${aws_region} | jq -r '.SecretString' > certificates.pem
aws secretsmanager get-secret-value --secret-id "/production/mgmt/ca/rootca/confluence_cert_key" --region ${aws_region} | jq -r '.SecretString' > private-key.pem
aws secretsmanager get-secret-value --secret-id "/production/mgmt/ca/rootca/root_ca_pub.pem" --region ${aws_region} | jq -r '.SecretString' > rootCA.crt

openssl pkcs12 -export -name confluence -in certificates.pem -inkey private-key.pem -out keystore.p12 -password pass:changeit 
/opt/atlassian/confluence/jre/bin/keytool -importkeystore -destkeystore confluence.jks -srckeystore keystore.p12 -srcstoretype pkcs12 -alias confluence -srcstorepass changeit -deststorepass changeit
/opt/atlassian/confluence/jre/bin/keytool -import -alias rootCA -keystore confluence.jks -file rootCA.crt -srcstorepass changeit -deststorepass changeit -noprompt

mv confluence.jks /opt/atlassian/confluence/
chown root:root /opt/atlassian/confluence/confluence.jks
chmod 644 /opt/atlassian/confluence/confluence.jks

/opt/atlassian/confluence/jre/bin/keytool -import -alias rootCA -keystore /opt/atlassian/confluence/jre/lib/security/cacerts -file rootCA.crt -srcstorepass changeit -deststorepass changeit -noprompt

mv /opt/atlassian/confluence/conf/server.xml /opt/atlassian/confluence/conf/server.xml.original
mv /opt/atlassian/confluence/confluence/WEB-INF/web.xml /opt/atlassian/confluence/confluence/WEB-INF/web.xml.original

aws s3 cp s3://${install_s3_bucket}/${install_s3_bucket_folder}/server.xml /opt/atlassian/confluence/conf/server.xml
aws s3 cp s3://${install_s3_bucket}/${install_s3_bucket_folder}/web.xml /opt/atlassian/confluence/confluence/WEB-INF/web.xml

chmod 644 /opt/atlassian/confluence/conf/server.xml
chmod 644 /opt/atlassian/confluence/conf/web.xml

#####
#Uncomment if deploying the rest of the Atlassian Stack
############
# #import jira CA cert
# aws secretsmanager get-secret-value --secret-id "/production/mgmt/ca/rootca/jira1_cert" --region ${aws_region} | jq -r '.SecretString' > jira-certificates.pem
# /opt/atlassian/confluence/jre/bin/keytool -import -alias jiraCA -file jira-certificates.pem -keystore confluence.jks -srcstorepass changeit -deststorepass changeit -noprompt
# /opt/atlassian/confluence/jre/bin/keytool -import -alias jiraCA -keystore /opt/atlassian/confluence/jre/lib/security/cacerts -file jira-certificates.pem -srcstorepass changeit -deststorepass changeit -noprompt

# #import bamboo
# aws secretsmanager get-secret-value --secret-id "/production/mgmt/ca/rootca/bamboo_cert" --region ${aws_region} | jq -r '.SecretString' > bamboo-certificates.pem
# /opt/atlassian/confluence/jre/bin/keytool -import -alias bambooCA -file bamboo-certificates.pem -keystore confluence.jks -srcstorepass changeit -deststorepass changeit -noprompt
# /opt/atlassian/confluence/jre/bin/keytool -import -alias bambooCA -keystore /opt/atlassian/confluence/jre/lib/security/cacerts -file bamboo-certificates.pem -srcstorepass changeit -deststorepass changeit -noprompt

# #import bitbucket
# aws secretsmanager get-secret-value --secret-id "/production/mgmt/ca/rootca/bitbucket_cert" --region ${aws_region} | jq -r '.SecretString' > bitbucket-certificates.pem
# /opt/atlassian/confluence/jre/bin/keytool -import -alias bitbucketCA -file bitbucket-certificates.pem -keystore confluence.jks -srcstorepass changeit -deststorepass changeit -noprompt 
# /opt/atlassian/confluence/jre/bin/keytool -import -alias bitbucketCA -keystore /opt/atlassian/confluence/jre/lib/security/cacerts -file bitbucket-certificates.pem -srcstorepass changeit -deststorepass changeit -noprompt

#Reboot instance to verify that service presist through reboot.
reboot


