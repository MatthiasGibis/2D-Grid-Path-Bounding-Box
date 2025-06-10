# 2D-Grid-Path-Bounding-Box

# setGibisBox

A bounding box algorithm in Swift that encapsulates the shortest path corridor between two positions on a 2D grid – even in the presence of obstacles.

## Description

This algorithm computes the **minimal bounding box** that contains **at least one valid shortest path** between a start and target position.
It dynamically expands the box to trace around obstacles, guaranteeing that any viable pathfinder (A*, Dijkstra, etc.) restricted to this box can still find the shortest possible path.

**Note:**
The setGibisBox algorithm does **not perform pathfinding** itself – instead, it **limits the search space** to the smallest possible area necessary to guarantee correctness.

**Important Limitation:**
The algorithm assumes **flat terrain** – it does **not account for elevation differences.**
If your pathfinding logic involves **height constraints**, the true shortest path is likely not contained within the computed box.

### Why Use It?

Traditional pathfinding algorithms explore the entire map or rely on heuristics to limit their scope.
setGibisBox delivers a **precise, obstacle-aware bounding box**, often reducing the number of tiles visited by **orders of magnitude**, without sacrificing optimality.

This makes it an ideal pre-processing step for:

- A*, Dijkstra, BFS, DFS, or any grid-based pathfinding
- Mobile/embedded use cases with tight performance constraints
- Games or simulations requiring real-time movement decisions

## How It Works

1. The algorithm initializes a straight-line bounding box between the start and target positions.
2. It attempts direct traversal along that line.
3. If blocked, it triggers an **obstacle-tracing routine**:
   - It follows the outline of impassable tiles (clockwise and counterclockwise),
   - And expands the bounding box to include these detours.
4. The result is the **tightest possible rectangular area** containing a valid path.

If no such path exists, the algorithm detects this early and aborts further processing.

## Memory Efficiency

- Requires no dynamic memory allocations.
- Uses only stack-based state and a shared walkability cache.
- Can be implemented with **constant memory** (O(1)), independent of grid size.

## Performance

Box computation time typically ranges between **2,000 and 3,000 nanoseconds**, depending on the distance between start and target and the complexity of obstacles in between.

Importantly, runtime is **independent of total grid size.**
Only the **size of the resulting bounding box** and the **outline of obstacles** influence performance.

## Benchmarking

You can benchmark the performance of this algorithm using the iOS app **mgSearch** on various grid scenarios.

### Example

```swift
let start = GridPos(col: 3, row: 7)
let target = GridPos(col: 24, row: 10)

start.pathFinderDummy(target: target) // Dummy using bounding box
