module Hornet
  rate_limiter.bucket(:stats, 3_u32, 1.minute)

  client.on_message_create(
    DiscordMiddleware::Prefix.new("<@213450769276338177> \u{1f4be}"),
    DiscordMiddleware::RateLimiter.new(
      rate_limiter,
      :stats,
      DiscordMiddleware::RateLimiterKey::UserID),
    Flipper.new("stats")) do |ctx|
    stats = GC.stats
    stats_string = String.build do |string|
      string << "```cr\n"
      string << "heap_size:      " << stats.heap_size << "\n"
      string << "free_bytes:     " << stats.free_bytes << "\n"
      string << "unmapped_bytes: " << stats.unmapped_bytes << "\n"
      string << "bytes_since_gc: " << stats.bytes_since_gc << "\n"
      string << "total_bytes:    " << stats.total_bytes << "\n"
      string << "```"
    end
    stats_field = Discord::EmbedField.new(
      "gc stats",
      stats_string,
      true)

    total_members = cache.members.map { |_guild, members| members.size }.sum
    cache_string = String.build do |string|
      string << "```cr\n"
      string << "users:       " << cache.users.size << "\n"
      string << "channels:    " << cache.channels.size << "\n"
      string << "guilds:      " << cache.guilds.size << "\n"
      string << "members:     " << total_members << "\n"
      string << "roles:       " << cache.roles.size << "\n"
      string << "dm_channels: " << cache.dm_channels.size << "\n"
      string << "```"
    end
    cache_field = Discord::EmbedField.new(
      "cache totals",
      cache_string,
      true)

    client.create_message(
      ctx.payload.channel_id,
      "**bot statistics**",
      Discord::Embed.new(fields: [stats_field, cache_field]))
  end
end