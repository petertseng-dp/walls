# Walls

Defend your bunkers from the invading... termites?

[![Build Status](https://travis-ci.org/petertseng-dp/walls.svg?branch=master)](https://travis-ci.org/petertseng-dp/walls)

# Notes

This problem is actually quite involved.
We have to use Menger's Theorem (the number of vertex-independent paths is equal to the min cut).
So now we have to use a min-cut algorithm.
Since the input graph has vertex capacities and the Edmonds-Karp algorithm uses edge capacities, we have to convert.
This is by splitting vertices into an in-vertex and an out-vertex, connected by an internal edge.
Any cell on which a wall can be built will have capacity 1 on its internal edge.
All other edges have infinite capacity.

We can reduce the number of vertices and edges by not creating them for impassable terrain cells.

The language didn't give any implementation trouble here.

Troubles came from bad author decisions, namely the choice of representing an infinite capacity as `nil` (at first).
I eventually switched to `Float64::INFINITY`.
The only reason I didn't do that at first was that I thought the types might have given me trouble.

This problem showed that I'm really rusty on how to do graph theory.
In particular, when searching for augmenting paths we have to use the residual graph,
which means that we have to consider outgoing and incoming edges both (`Node#flow` not just `Node#out_edges`).
Same for determining the cut - the cut is formed by finding nodes reachable from the source on *the residual graph*.
If only considering outgoing edges, the walls appear in nonsensical locations.

# Source

https://www.reddit.com/r/dailyprogrammer/comments/26oop1/
