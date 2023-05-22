const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Edge = struct {
    from: i32,
    to: i32,
    weight: i32,

    const Self = @This();

    // needed for Kruskal sorting (see kruskal.zig)
    pub fn ascend(ctx: void, this: Edge, that: Edge) bool {
        _ = ctx;
        return this.weight < that.weight;
    }
};

pub fn UnionFind(comptime T: type) type {
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
        pub fn merge(self: Self, edge: Edge) void {
            const from = @intCast(usize, edge.from);
            const to = @intCast(usize, edge.to);
            const f = self.forest;
            const x = self.find(from);
            const y = self.find(to);
            if (f[x].rank < f[y].rank) {
                f[x].parent = y;
            } else if (f[x].rank > f[y].rank) {
                f[y].parent = x;
            } else {
                f[y].parent = x;
                f[x].rank += 1;
            }
        }

        pub fn same(self: Self, e: Edge) bool {
            const from = @intCast(usize, e.from);
            const to = @intCast(usize, e.to);
            return self.find(from) == self.find(to);
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
