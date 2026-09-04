const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

extern fn web_new(path: [*:0]const u8) void;
extern fn web_delete(path: [*:0]const u8) void;
extern fn web_exists_file(path: [*:0]const u8) bool;
extern fn web_write_file(path: [*:0]const u8, data: [*:0]const u8) void;
extern fn web_read_file(path: [*:0]const u8) ?[*:0]u8;

//

export fn alloc_string(size: usize) [*]u8 {
    const allocator = std.heap.wasm_allocator;
    const slice = allocator.alloc(u8, size) catch @panic("OOM");
    return slice.ptr;
}

//

pub fn new(allocator: std.mem.Allocator, path: []const u8) void {
    _ = allocator;

    var path_buf: [256]u8 = undefined;
    const c_path = api.global.c_string(&path_buf, path);
    web_new(c_path.ptr);
}
pub fn delete(path: []const u8) void {
    var path_buf: [256]u8 = undefined;
    const c_path = api.global.c_string(&path_buf, path);
    web_delete(c_path.ptr);
}

pub fn write(
    allocator: std.mem.Allocator,
    path: []const u8,
    category: []const u8,
    name: []const u8,
    data: []const u8,
) void {
    var path_buf: [256]u8 = undefined;
    const c_path = api.global.c_string(&path_buf, path);

    if (!web_exists_file(c_path.ptr)) {
        new(allocator, path);
    }

    var key_buf: [256]u8 = undefined;
    const flat_key = std.fmt.bufPrint(&key_buf, "{s}.{s}", .{ category, name }) catch {
        @panic("key path too long");
    };

    const raw_contents = web_read_file(c_path.ptr);
    const contents = if (raw_contents) |ptr| std.mem.span(ptr) else "";

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

    const term_content = allocator.dupeZ(u8, new_content.items) catch @panic("oom");
    defer allocator.free(term_content);

    web_write_file(c_path.ptr, term_content.ptr);
}
pub fn read(
    allocator: std.mem.Allocator,
    path: []const u8,
    category: []const u8,
    name: []const u8,
) []u8 {
    var path_buf: [256]u8 = undefined;
    const c_path = api.global.c_string(&path_buf, path);

    if (!web_exists_file(c_path.ptr)) {
        new(allocator, path);
    }

    var key_buf: [256]u8 = undefined;
    const flat_key = std.fmt.bufPrint(&key_buf, "{s}.{s}", .{ category, name }) catch {
        @panic("key path too long");
    };

    const raw_contents = web_read_file(c_path.ptr) orelse @panic("save file not found");
    const contents = std.mem.span(raw_contents);

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
