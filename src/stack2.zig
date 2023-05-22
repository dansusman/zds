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

        pub fn push(self: *Self, value: T) !void {
            const new_node = try self.alloc.create(Node);
            new_node.data = value;

            new_node.next = self.head;
            self.head = new_node;
        }

        pub fn pop(self: *Self) ?T {
            if (self.head) |head| {
                const value = head.data;
                self.head = head.next;
                self.alloc.destroy(head);
                return value;
            }

            return null;
        }

        pub fn print(self: *Self) void {
            var curr = self.head;
            std.log.info("stack: ", .{});
            while (curr) |current| : (curr = current.next) {
                std.log.info("-> {d}", .{current.data});
            }
        }
    };
}

const IntStack = Stack(i32);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var stack = IntStack.init(alloc);

    try stack.push(45);
    stack.print();
    try stack.push(69);
    stack.print();
    try stack.push(420);
    stack.print();

    _ = stack.pop();
    stack.print();
    _ = stack.pop();
    stack.print();
    _ = stack.pop();
    stack.print();
}
