# 1. ビルド環境: Maven + JDK 17
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# 設定ファイルとソースコードのコピー
COPY pom.xml .
COPY src ./src

# WARファイルの自動ビルド（ROOT.war を生成）
RUN mvn clean package -DskipTests

# 2. 実行環境: Apache Tomcat 10 (Jakarta EE対応)
FROM tomcat:10.1-jdk17-temurin

# デフォルトのROOTアプリを削除し、ビルドしたROOT.warを配置
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY --from=build /app/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war

# クラウド向けポート開放とTomcat起動
EXPOSE 8080
CMD ["catalina.sh", "run"]