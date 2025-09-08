# 使用官方的 Maven 镜像作为构建环境
FROM maven:3-eclipse-temurin-22-alpine as builder

# 设置工作目录
WORKDIR /app

# 将你的 Maven 项目文件（pom.xml）复制到工作目录中
COPY pom.xml .

# 将项目的源代码复制到工作目录中
COPY src ./src

# 使用 Maven 打包你的应用
RUN mvn clean package -DskipTests

# ----- 构建阶段结束，现在创建一个更小的运行时镜像 -----

# 使用轻量级的 JRE 镜像作为最终的应用运行环境
FROM eclipse-temurin:22-jre-alpine

# 安装中文字体和字符编码支持
RUN apk add --no-cache \
    curl \
    fontconfig \
    ttf-dejavu \
    && fc-cache -f

# 设置环境变量支持中文
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Shanghai

# 将构建阶段生成的 JAR 文件复制到这个新镜像中
COPY --from=builder /app/target/*.jar app.jar

# 暴露应用所使用的端口
EXPOSE 8081

# 启动你的 Spring Boot 应用，添加字符编码参数
ENTRYPOINT ["java", "-Dfile.encoding=UTF-8", "-Duser.timezone=Asia/Shanghai", "-jar", "/app.jar"]