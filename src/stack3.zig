const std = @import("std");
const testing = std.testing;

fn Stack(comptime T: type) type {
    return struct {
        head: ?*Node,
        alloc: std.mem.Allocator,

        pub const Self = @This();
        pub const Node = struct {
            data: T,
            next: ?*Node,
        };

        pub fn init(alloc: std.mem.Allocator) Self {
            return Self{
                .head = null,
                .alloc = alloc,
            };
        }

        pub fn push(self: *Self, new_val: T) !void {
            const new_node = try self.alloc.create(Node);
            new_node.data = new_val;

            new_node.next = self.head;
            self.head = new_node;
        }

        pub fn pop(self: *Self) ?T {
            if (self.head) |head| {
                const result = head.data;
                defer self.alloc.destroy(head);
                self.head = head.next;
                return result;
            }
            return null;
        }

        pub fn print(self: *Self) void {
            var curr = self.head;
            while (curr) |current| : (curr = current.next) {
                std.log.info("{d}", .{current.data});
            }
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var stack = Stack(i32).init(alloc);

    std.log.info("Stack beginning: ", .{});
    stack.print();
    std.log.info("--------", .{});
    try stack.push(45);
    stack.print();
    std.log.info("--------", .{});
    try stack.push(69);
    stack.print();
    std.log.info("--------", .{});
    try stack.push(420);
    stack.print();
    std.log.info("--------", .{});

    std.log.info("Stack popping: ", .{});
    _ = stack.pop();
    stack.print();
    std.log.info("--------", .{});
    _ = stack.pop();
    stack.print();
    std.log.info("--------", .{});
    _ = stack.pop();
    stack.print();
    std.log.info("--------", .{});
}
