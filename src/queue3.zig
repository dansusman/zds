const std = @import("std");

fn Queue(comptime T: type) type {
    return struct {
        head: ?*Node,
        tail: ?*Node,
        alloc: std.mem.Allocator,

        pub const Self = @This();
        pub const Node = struct {
            data: T,
            next: ?*Node,
        };

        pub fn init(alloc: std.mem.Allocator) Self {
            return Self{
                .head = null,
                .tail = null,
                .alloc = alloc,
            };
        }

        pub fn enqueue(self: *Self, new_val: T) !void {
            var new_node = try self.alloc.create(Node);
            new_node.data = new_val;
            new_node.next = null;

            if (self.tail) |tail| {
                tail.next = new_node;
            } else {
                self.head = new_node;
            }
            self.tail = new_node;
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.head) |head| {
                defer self.alloc.destroy(head);
                self.head = head.next;
                if (self.head == null) {
                    self.tail = null;
                }
                return head.data;
            }
            return null;
        }

        pub fn print(self: *Self) void {
            var curr = self.head;
            std.log.info("Queue: ", .{});
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

    var queue = Queue(i32).init(alloc);

    try queue.enqueue(34);
    queue.print();
    std.log.info("--------", .{});
    try queue.enqueue(35);
    queue.print();
    std.log.info("--------", .{});
    try queue.enqueue(69);
    queue.print();
    std.log.info("--------", .{});
    try queue.enqueue(420);
    queue.print();
    std.log.info("--------", .{});
    std.log.info("--------", .{});
    queue.print();
    std.log.info("--------", .{});
    _ = queue.dequeue();
    queue.print();
    std.log.info("--------", .{});
    _ = queue.dequeue();
    queue.print();
    std.log.info("--------", .{});
    _ = queue.dequeue();
    queue.print();
    std.log.info("--------", .{});
    _ = queue.dequeue();
    queue.print();
    std.log.info("--------", .{});
}
