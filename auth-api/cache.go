package main

import (
    "context"
    "fmt"
    "time"
    
    "github.com/go-redis/redis/v8"
)

type CacheService struct {
    client *redis.Client
    ctx    context.Context
    ttl    time.Duration
}

func NewCacheService(addr, password string) *CacheService {
    rdb := redis.NewClient(&redis.Options{
        Addr:     addr,
        Password: password,
        DB:       0,
    })
    
    return &CacheService{
        client: rdb,
        ctx:    context.Background(),
        ttl:    time.Hour,
    }
}

// Cache Aside Pattern - Get from cache first
func (c *CacheService) GetToken(key string) (string, error) {
    val, err := c.client.Get(c.ctx, fmt.Sprintf("auth:token:%s", key)).Result()
    if err == redis.Nil {
        return "", nil // Cache miss
    } else if err != nil {
        return "", err
    }
    
    return val, nil
}

// Cache Aside Pattern - Set in cache after database operation
func (c *CacheService) SetToken(key, token string) error {
    return c.client.Set(c.ctx, fmt.Sprintf("auth:token:%s", key), token, c.ttl).Err()
}

// Cache Aside Pattern - Invalidate cache entry
func (c *CacheService) InvalidateToken(key string) error {
    return c.client.Del(c.ctx, fmt.Sprintf("auth:token:%s", key)).Err()
}

// Health check for cache
func (c *CacheService) HealthCheck() error {
    return c.client.Ping(c.ctx).Err()
}