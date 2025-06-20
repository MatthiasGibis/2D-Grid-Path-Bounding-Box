Algorithm: setGibisBox
Autor: Matthias Gibis
Created: 10.06.2025
Copyright (c) 2025 Matthias Gibis

struct GridPos {
    let col: Int
    let row: Int
    
    /// Initializes a new grid position.
    init(col: Int, row: Int) {
        self.col = col
        self.row = row
    }

    static var mapWidth: Int = 32
    static var mapHeight: Int = 32

    static var walkAbleTileCache = Array( 		// row | col
           repeating: Array(repeating: true,
           count: mapWidth),
           count: mapHeight
    )
    
    /// Dummy pathfinding function. Intended to be replaced by a real algorithm (A*, Dijkstra, etc.).
    func pathFinderDummy(target: GridPos) -> [GridPos] {
        // 2D cache of walkable tiles (precomputed static data)
        let cache = GridPos.walkAbleTileCache
        
        // Extract target position (column and row)
        let endPos = (row: target.row, col: target.col)
        
        // Initialize bounding box around start and target positions.
        var boundingBoxMinCol = min(col, endPos.col)
        var boundingBoxMaxCol = max(col, endPos.col)
        var boundingBoxMinRow = min(row, endPos.row)
        var boundingBoxMaxRow = max(row, endPos.row)
        
        // Expand bounding box using tracing in both directions.

        var shouldEndSearch = false
        setGibisBox(startCol: self.col, startRow: self.row, endCol: endPos.col, endRow: endPos.row)
        if shouldEndSearch { return [] }
        setGibisBox(startCol: endPos.col, startRow: endPos.row, endCol: self.col, endRow: self.row)
        setGibisBox(startCol: boundingBoxMinCol, startRow: boundingBoxMinRow, endCol: boundingBoxMaxCol, endRow: boundingBoxMaxRow)
        setGibisBox(startCol: boundingBoxMaxCol, startRow: boundingBoxMaxRow, endCol: boundingBoxMinCol, endRow: boundingBoxMinRow)
        
        // Final path to return (currently empty).
        var finalPath: [GridPos] = []
        
        //your path algorithm like A*, Dijkstra, BFS, DFS, Greedy
        
        //you probably have something like:
    
        //#### if nextCol < 0 || nextCol >= mapWidth || nextRow < 0 || nextRow >= mapHeight {continue} ####
        
        //#### change it to -> if !isWithinBounds(nextRow, nextCol) {continue} ####
        
        return finalPath
        //
        
        /// Checks whether a given (row, col) is within the current bounding box.
        func isWithinBounds(_ y: Int, _ x: Int)->Bool{
            x >= boundingBoxMinCol && x <= boundingBoxMaxCol &&
            y >= boundingBoxMinRow && y <= boundingBoxMaxRow
        }
        
        /// Expands a bounding box by tracing an outline around obstacles between two points.
        func setGibisBox(startCol: Int, startRow: Int, endCol: Int, endRow: Int) {
            // Direction vectors for 4-way movement (right, down, left, up)
            let dxs = [0, 1, 0, -1]
            let dys = [1, 0, -1, 0]
            
            var currentRow = startRow, currentCol = startCol
            
            // Determine step direction on X and Y axes (−1, 0, or +1)
            let stepX = endCol > currentCol ? 1 : -1
            let stepY = endRow > currentRow ? 1 : -1
            
            // Alternative way to access cache quickly – slightly faster (by a few ns),
            // but less readable than "cache[currentRow][currentCol]"
            var fastCacheAccess: Bool {
                cache.withUnsafeBufferPointer({ $0[currentRow] })
                     .withUnsafeBufferPointer({ $0[currentCol] })
            }
            
            // Side length of the square map (used for bounds checking)
            let cacheCount = cache.count
            
            for startOutlineDir in [1, 3] { // Try both clockwise and counter-clockwise
                currentRow = startRow
                currentCol = startCol
                
                while true {
                    // Move horizontally towards the target column while on walkable tiles
                    while currentCol != endCol, fastCacheAccess {
                        currentCol += stepX
                    }
                    // If stepped onto a non-walkable tile, step back
                    if !fastCacheAccess {
                        currentCol -= stepX
                    }
                    // If aligned horizontally, move vertically towards the target row
                    if currentCol == endCol {
                        while currentRow != endRow, fastCacheAccess {
                            currentRow += stepY
                        }
                        // Step back if stepped onto a non-walkable tile
                        if !fastCacheAccess {
                            currentRow -= stepY
                        }
                    }
                    
                    // If reached the target position, continue
                    if currentCol == endCol && currentRow == endRow { break  }
                    
                    // Save current position as start for outline tracing
                    let startX = currentCol, startY = currentRow
                    
                    // Helper to check if we've reached the other side (aligned with target)
                    
                    // Initialize direction for outline following:
                    // 0=up,1=right,2=down,3=left
                    var dir = ((endCol != currentCol ? (stepX == 1 ? 0 : 2) : (stepY == 1 ? 3 : 1)) + (startOutlineDir == 1 ? 0 : 2)) & 3
                    var startDirValue = dir
                    var outlineDir = startOutlineDir // direction increment (1 = clockwise)
                    
                    // Save bounding box limits before tracing to restore them if we go out of bounds
                    let xMinLimitBefore = boundingBoxMinCol
                    let xMaxLimitBefore = boundingBoxMaxCol
                    let yMinLimitBefore = boundingBoxMinRow
                    let yMaxLimitBefore = boundingBoxMaxRow

                    // Begin outline following loop to find a path around obstacles
                    while true {
                        visitedCount += 1
                        currentCol += dxs[dir]
                        currentRow += dys[dir]

                        // Check for out-of-bounds and handle accordingly
                        if currentCol < 0 || currentRow < 0 || currentCol >= cacheCount || currentRow >= cacheCount {
                            if outlineDir == 4 - startOutlineDir {
                                // Already tried both directions and went out of map a second time,
                                // so the start or target tile cannot be reached
                                shouldEndSearch = true
                                return
                            }
                            dir = (startDirValue + 2) & 3 // turn 180 degrees
                            
                            startDirValue = 4
                            
                            outlineDir = 4 - startOutlineDir // change clockwise direction
                            
                            currentCol = startX // reset position to start of outline trace
                            currentRow = startY //
                            
                            boundingBoxMinCol = xMinLimitBefore
                            boundingBoxMaxCol = xMaxLimitBefore
                            boundingBoxMinRow = yMinLimitBefore
                            boundingBoxMaxRow = yMaxLimitBefore
                        } else if !fastCacheAccess {
                            // blocked?, turn direction counterclockwise and continue
                            currentCol -= dxs[dir]
                            currentRow -= dys[dir]
                            dir = (dir - outlineDir) & 3
                        } else {
                            dir = (dir + outlineDir) & 3 // rotate direction clockwise or counterclockwise
                            currentCol += dxs[dir]
                            currentRow += dys[dir]
                            
                            if !fastCacheAccess {
                                currentCol -= dxs[dir]
                                currentRow -= dys[dir]
                                dir = (dir - outlineDir) & 3
                            }

                             // Found valid tile, update bounding box
                            boundingBoxMaxCol = max(boundingBoxMaxCol, currentCol)
                            boundingBoxMinCol = min(boundingBoxMinCol, currentCol)
                            boundingBoxMaxRow = max(boundingBoxMaxRow, currentRow)
                            boundingBoxMinRow = min(boundingBoxMinRow, currentRow)
                            
                            if currentRow == self.row {
                                if stepX == 1 ? (currentCol > startX && currentCol <= endCol) : (currentCol < startX && currentCol >= endCol) {
                                    // found a path around obstacle to target
                                    break
                                }
                            } else if currentCol == endCol {
                                if stepY == 1 ? (currentRow > startY && currentRow <= endRow) : (currentRow < startY && currentRow >= endRow) {
                                    // found a path around obstacle to target
                                    break
                                }
                            }
                        }

                        // If returned to the start position and direction, we've looped in a circle,
                        // meaning the start or target is trapped with no path available
                        if currentCol == startX, currentRow == startY, dir == startDirValue {
                            shouldEndSearch = true
                            return
                        }
                    }
                }
            }
        }
    }
}
