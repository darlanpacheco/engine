const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn write(
    allocator: std.mem.Allocator,
    path: []const u8,
    key: []const u8,
    data: []const u8,
) void {
    // If the file doesn't exist, c_read_file fails, and we fallback to an empty string.
    // This naturally handles creating a new file on write.
    const contents = engine.global.c_read_file(allocator, path) catch blk: {
        break :blk allocator.dupe(u8, "") catch @panic("oom");
    };
    defer allocator.free(contents);

    var found = false;

    var new_content: std.ArrayList(u8) = .empty;
    defer new_content.deinit(allocator);

    var line_it = std.mem.splitScalar(u8, contents, '\n');

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.indexOfScalar(u8, line, '=')) |eq_idx| {
            const current_key = line[0..eq_idx];

            if (std.mem.eql(u8, current_key, key)) {
                const formatted = std.fmt.allocPrint(
                    allocator,
                    "{s}={s}\n",
                    .{ key, data },
                ) catch @panic("oom");
                defer allocator.free(formatted);

                new_content.appendSlice(allocator, formatted) catch @panic("oom");
                found = true;
                continue;
            }
        }

        const formatted = std.fmt.allocPrint(
            allocator,
            "{s}\n",
            .{line},
        ) catch @panic("oom");
        defer allocator.free(formatted);

        new_content.appendSlice(allocator, formatted) catch @panic("oom");
    }

    if (!found) {
        const formatted = std.fmt.allocPrint(
            allocator,
            "{s}={s}\n",
            .{ key, data },
        ) catch @panic("oom");
        defer allocator.free(formatted);

        new_content.appendSlice(allocator, formatted) catch @panic("oom");
    }

    engine.global.c_write_file(
        allocator,
        path,
        new_content.items,
    );
}

pub fn read(
    allocator: std.mem.Allocator,
    path: []const u8,
    key: []const u8,
) []u8 {
    const contents = engine.global.c_read_file(
        allocator,
        path,
    ) catch {
        @panic("save file not found");
    };
    defer allocator.free(contents);

    var line_it = std.mem.splitScalar(u8, contents, '\n');

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.indexOfScalar(u8, line, '=')) |eq_idx| {
            const current_key = line[0..eq_idx];
            const current_val = line[eq_idx + 1 ..];

            if (std.mem.eql(u8, current_key, key)) {
                return allocator.dupe(
                    u8,
                    current_val,
                ) catch @panic("oom");
            }
        }
    }

    @panic("Save key not found");
}
