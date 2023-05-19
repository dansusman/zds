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

        pub fn push(self: *Self, new: T) !void {
            var node = try self.alloc.create(Node);
            node.data = new;

            var curr = self.head;
            node.next = curr;
            self.head = node;
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

        pub fn peak(self: *Self) ?T {
            if (self.head) |head| {
                return head.data;
            }
            return null;
        }
    };
}

test "basic stack functionality" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var stack = Stack(i32).init(alloc);

    try testing.expect(stack.head == null);
    try stack.push(5);
    try testing.expect(stack.head.?.data == 5);
    try stack.push(6);
    try testing.expect(stack.head.?.data == 6);
    try testing.expect(stack.head.?.next.?.data == 5);
    const result = stack.peak();
    if (result) |r| {
        try testing.expect(r == 6);
    }
    try testing.expect(stack.head.?.data == 6);
    try testing.expect(stack.head.?.next.?.data == 5);
    const pop_res = stack.pop();
    if (pop_res) |r| {
        try testing.expect(r == 6);
    }
    try testing.expect(stack.head.?.data == 5);
    try testing.expect(stack.head.?.next == null);
    _ = stack.pop();
    try testing.expect(stack.head == null);
}
