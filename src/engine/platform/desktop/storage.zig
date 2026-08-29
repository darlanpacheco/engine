const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

pub fn new(allocator: std.mem.Allocator, path: []const u8) void {
    engine.global.c_write_file(allocator, path, "");
}
pub fn delete(path: []const u8) void {
    std.fs.cwd().deleteFile(path) catch {
        @panic("failed to delete save file");
    };
}

pub fn write(
    allocator: std.mem.Allocator,
    path: []const u8,
    category: []const u8,
    name: []const u8,
    data: []const u8,
) void {
    var key_buf: [256]u8 = undefined;
    const flat_key = std.fmt.bufPrint(&key_buf, "{s}.{s}", .{ category, name }) catch {
        @panic("key path too long");
    };

    const contents = engine.global.c_read_file(allocator, path) catch blk: {
        break :blk allocator.dupe(u8, "") catch @panic("oom");
    };
    defer allocator.free(contents);

    var found = false;
    var new_content: std.ArrayList(u8) = .empty;
    defer new_content.deinit(allocator);

    var last_category: ?[]const u8 = null;
    var line_it = std.mem.splitScalar(u8, contents, '\n');

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var line_cat: []const u8 = "";
        if (std.mem.indexOfScalar(u8, line, '.')) |dot_idx| {
            line_cat = line[0..dot_idx];
        }

        if (last_category) |last_cat| {
            if (!std.mem.eql(u8, last_cat, line_cat)) {
                new_content.appendSlice(allocator, "\n") catch @panic("oom");
            }
        }
        last_category = line_cat;

        if (std.mem.indexOfScalar(u8, line, '=')) |eq_idx| {
            if (std.mem.eql(u8, line[0..eq_idx], flat_key)) {
                const formatted = std.fmt.allocPrint(
                    allocator,
                    "{s}={s}\n",
                    .{ flat_key, data },
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
        if (last_category != null and !std.mem.eql(u8, last_category.?, category)) {
            new_content.appendSlice(allocator, "\n") catch @panic("oom");
        }

        const formatted = std.fmt.allocPrint(
            allocator,
            "{s}={s}\n",
            .{ flat_key, data },
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
    category: []const u8,
    name: []const u8,
) []u8 {
    var key_buf: [256]u8 = undefined;
    const flat_key = std.fmt.bufPrint(&key_buf, "{s}.{s}", .{ category, name }) catch {
        @panic("key path too long");
    };

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
            if (std.mem.eql(u8, line[0..eq_idx], flat_key)) {
                return allocator.dupe(
                    u8,
                    line[eq_idx + 1 ..],
                ) catch @panic("oom");
            }
        }
    }

    @panic("save key not found");
}
