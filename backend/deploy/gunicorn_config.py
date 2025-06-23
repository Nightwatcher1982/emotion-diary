# Gunicorn配置文件
import multiprocessing
import os

# 绑定地址和端口
bind = "127.0.0.1:8000"

# 工作进程数量
workers = multiprocessing.cpu_count() * 2 + 1

# 工作进程类型
worker_class = "sync"

# 每个工作进程的线程数
threads = 2

# 工作进程连接数
worker_connections = 1000

# 最大客户端并发数量
max_requests = 1000

# 随机化max_requests，防止所有进程同时重启
max_requests_jitter = 100

# 进程超时时间（秒）
timeout = 60

# 保持连接时间（秒）
keepalive = 2

# 预加载应用
preload_app = True

# 用户和组
user = "www-data"
group = "www-data"

# 进程文件
pidfile = "/var/run/emotion-diary/gunicorn.pid"

# 日志配置
accesslog = "/var/log/emotion-diary/gunicorn-access.log"
errorlog = "/var/log/emotion-diary/gunicorn-error.log"
loglevel = "info"

# 访问日志格式
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# 进程名称
proc_name = "emotion-diary-api"

# 临时目录
tmp_upload_dir = "/tmp"

# 环境变量
raw_env = [
    'DJANGO_SETTINGS_MODULE=emotion_diary_api.settings_production',
]

# 重启前的回调
def on_starting(server):
    server.log.info("Starting Emotion Diary API server...")

def on_reload(server):
    server.log.info("Reloading Emotion Diary API server...")

def worker_int(worker):
    worker.log.info("Worker received INT or QUIT signal")

def pre_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def worker_abort(worker):
    worker.log.info("Worker received SIGABRT signal") 