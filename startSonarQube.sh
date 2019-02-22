#!/bin/sh

echo "-----> Making java available"
export PATH=$PATH:/home/vcap/app/.java/bin

echo "-----> Setting sonar.properties"
echo "       sonar.web.port=${PORT}"
echo "\n ------- The following properties were automatically created by the buildpack -----\n" >> ./sonar.properties
echo "sonar.web.port=${PORT}\n" >> ./sonar.properties
echo "sonar.jdbc.username=${JDBC_NAME}\n" >> ./sonar.properties
echo "sonar.jdbc.password=${JDBC_PASS}\n" >> ./sonar.properties
echo "sonar.jdbc.url=${JDBC_URL}\n" >> ./sonar.properties
cat ./sonar.properties
# Replace all environment variables with syntax ${MY_ENV_VAR} with the value
# thanks to https://stackoverflow.com/questions/5274343/replacing-environment-variables-in-a-properties-file
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg; s/\$\{([^}]+)\}//eg' ./sonar.properties > ./sonar_replaced.properties
mv ./sonar_replaced.properties ./sonar.properties

echo "------------------------------------------------------" > /home/vcap/app/sonarqube/logs/sonar.log

wget http://download.oracle.com/otn/utilities_drivers/jdbc/121010/ojdbc7.jar
wget --no-check-certificate -q -c \
        --header "Cookie: oraclelicense=accept-securebackup-cookie" \
        http://download.oracle.com/otn/utilities_drivers/jdbc/121010/ojdbc7.jar
cp ojdbc7.jar /home/vcap/app/sonarqube/extensions/jdbc-driver/oracle/ojdbc7.jar

echo "-----> Starting SonarQube"

/home/vcap/app/sonarqube/bin/linux-x86-64/sonar.sh start

echo "-----> Tailing log"
sleep 10 # give it a bit of time to create files
cd /home/vcap/app/sonarqube/logs
tail -f ./sonar.log ./es.log ./web.log ./ce.log ./access.log
