const std = @import("std");
const Allocator = std.mem.Allocator;

fn UnionFind(comptime T: type) type {
    return struct {
        forest: []Tree,

        pub const Self = @This();
        pub const Tree = struct {
            parent: T,
            rank: usize,
        };

        pub fn init(size: usize, alloc: Allocator) !Self {
            const a = try alloc.alloc(Tree, size);
            for (a, 0..) |_, idx| {
                a[idx] = Tree{
                    .parent = idx,
                    .rank = 1,
                };
            }
            return Self{
                .forest = a,
            };
        }

        pub fn find(self: Self, x: T) T {
            const f = self.forest;
            if (f[x].parent != x) {
                f[x].parent = self.find(f[x].parent);
            }
            return f[x].parent;
        }

        // `union' is a keyword in Zig, so I have to call this method `merge'
        pub fn merge(self: Self, x: T, y: T) void {
            const f = self.forest;
            const rx = self.find(x);
            const ry = self.find(y);
            if (f[rx].rank < f[ry].rank) {
                f[rx].parent = ry;
            } else if (f[rx].rank > f[ry].rank) {
                f[ry].parent = rx;
            } else {
                f[ry].parent = rx;
                f[rx].rank += 1;
            }
        }

        pub fn same(self: Self, x: T, y: T) bool {
            return self.find(x) == self.find(y);
        }

        pub fn print(self: Self) void {
            for (self.forest) |tree| {
                std.log.info("{d}, {d}", .{ tree.parent, tree.rank });
            }
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const uf = try UnionFind(usize).init(11, arena.allocator());

    uf.print();
    uf.merge(1, 2);
    uf.merge(2, 3);
    uf.merge(4, 9);
    uf.print();
}
