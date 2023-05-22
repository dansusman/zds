const std = @import("std");
const testing = std.testing;

fn Queue(comptime T: type) type {
    return struct {
        head: ?*Node,
        tail: ?*Node,
        alloc: std.mem.Allocator,

        const Self = @This();

        pub const Node = struct {
            next: ?*Node = null,
            data: T,
        };

        pub fn init(alloc: std.mem.Allocator) Self {
            return .{
                .head = null,
                .tail = null,
                .alloc = alloc,
            };
        }

        pub fn enqueue(self: *Self, new: T) !void {
            var node = try self.alloc.create(Node);
            node.data = new;
            node.next = null;
            if (self.tail) |tail| {
                tail.next = node;
                self.tail = node;
            } else {
                // if queue is empty, add new node to front and back
                self.head = node;
                self.tail = node;
            }
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.head) |head| {
                // if queue is non-empty, remove the head and return it
                var tmp = head;
                self.head = head.next;

                if (self.head == null) {
                    self.tail = null;
                }

                self.alloc.destroy(head);

                return tmp.data;
            }

            return null;
        }

        pub fn print(self: *Self) void {
            var curr = self.head;
            std.log.info("queue: ", .{});
            while (curr) |node| {
                std.log.info(" -> {d}", .{node.data});
                curr = node.next;
            }
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var queue = Queue(i32).init(alloc);
    try queue.enqueue(5);
    std.log.info("1: {d}", .{queue.tail.?.data});
    try queue.enqueue(6);
    std.log.info("2: {d}", .{queue.tail.?.data});
    std.log.info("3: {d}", .{queue.head.?.data});
    queue.print();
    const deq_res = queue.dequeue();
    if (deq_res) |r| {
        std.log.info("4: {d}", .{r});
    }
    queue.print();
    const deq_res2 = queue.dequeue();
    if (deq_res2) |r| {
        std.log.info("5: {d}", .{r});
    }
    queue.print();
}

test "basic queue functionality" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var queue = Queue(i32).init(alloc);

    try testing.expect(queue.head == null);
    try queue.enqueue(5);
    try testing.expect(queue.head.?.data == 5);
    try testing.expect(queue.tail.?.data == 5);
    try queue.enqueue(6);
    try testing.expect(queue.head.?.data == 5);
    try testing.expect(queue.head.?.next.?.data == 6);
    try testing.expect(queue.tail.?.data == 6);
    const deq_res = queue.dequeue();
    if (deq_res) |r| {
        try testing.expect(r == 5);
    }
    try testing.expect(queue.head.?.data == 6);
    try testing.expect(queue.tail.?.data == 6);
    try testing.expect(queue.head.?.next == null);
    _ = queue.dequeue();
    try testing.expect(queue.head == null);
    try testing.expect(queue.tail == null);
}
