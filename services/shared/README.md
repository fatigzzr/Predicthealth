# Run Redis

# Pull Redis image
On an elevated CMD, use:

docker pull redis:7

# Run Redis container
docker run -d --name predicthealth-redis -p 6379:6379 redis:7
