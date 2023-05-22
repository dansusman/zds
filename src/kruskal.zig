const std = @import("std");
const uf = @import("unionfind.zig");
const sort = std.sort;
const testing = std.testing;

const Allocator = std.mem.Allocator;

// https://en.wikipedia.org/wiki/Kruskal%27s_algorithm
fn kruskal(graph: []const uf.Edge, vertices: usize, allocator: Allocator) !?[]const uf.Edge {
    const f = try uf.UnionFind(usize).init(vertices, allocator);
    var mst = try allocator.alloc(uf.Edge, vertices - 1); // |MST| is O(n - 1)
    var i: usize = 0;
    for (graph) |e| {
        if (i == vertices - 1) {
            return mst;
        }

        if (!f.same(e)) {
            f.merge(e);
            mst[i] = e;
            i += 1;
        }
    }
    return null;
}

inline fn edge(from: i32, to: i32, weight: i32) uf.Edge {
    return uf.Edge{
        .from = from,
        .to = to,
        .weight = weight,
    };
}

fn initialize_edges() []uf.Edge {
    var edges: [11]uf.Edge = undefined;
    edges[0] = edge(0, 1, 7);
    edges[1] = edge(0, 3, 5);
    edges[2] = edge(1, 2, 8);
    edges[3] = edge(1, 4, 7);
    edges[4] = edge(1, 3, 9);
    edges[5] = edge(2, 4, 5);
    edges[6] = edge(3, 4, 15);
    edges[7] = edge(3, 5, 6);
    edges[8] = edge(4, 5, 8);
    edges[9] = edge(4, 6, 9);
    edges[10] = edge(5, 6, 11);

    return &edges;
}

fn initialize_answer() []uf.Edge {
    var answer: [6]uf.Edge = undefined;
    answer[0] = edge(0, 3, 5);
    answer[1] = edge(2, 4, 5);
    answer[2] = edge(3, 5, 6);
    answer[3] = edge(0, 1, 7);
    answer[4] = edge(1, 4, 7);
    answer[5] = edge(4, 6, 9);
    return &answer;
}

test "MST" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var edges = initialize_edges();
    var answer = initialize_answer();
    sort.sort(uf.Edge, edges, {}, uf.Edge.ascend);

    const minST = try kruskal(edges, 6, arena.allocator());

    try testing.expect(minST != null);

    if (minST) |mst| {
        for (mst, 0..) |e, idx| {
            try testing.expectEqual(e, answer[idx]);
        }
    }
}
