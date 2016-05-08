
import Foundation

extension Dictionary where Key: IntegerType, Value: IntegerType {
    mutating func addToKey(key: Key, _ delta: Value) {
        if let oldValue = self[key] {
            self[key] = oldValue + delta
        } else {
            self[key] = delta
        }
    }
    func multiply(dict: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var r = Dictionary<Key,Value>()
        flatMap { a in dict.map { b in (a.0 + b.0, a.1 * b.1) } }.forEach { r.addToKey($0,$1)}
        return r;
    }
    func multiply(n: Value) -> Dictionary<Key,Value> {
        var r = Dictionary<Key,Value>()
        forEach{ r[$0.0] = n * $0.1 }
        return r
    }
    func add(d: Key) -> Dictionary<Key,Value> {
        var r = Dictionary<Key,Value>()
        forEach { r.addToKey($0.0 + d, $0.1) }
        return r
    }
    mutating func add(dict: Dictionary<Key,Value>) {
        dict.forEach { self.addToKey($0.0, $0.1) }
    }
}

class Graph: CustomStringConvertible {
    
    var nodesCount: Int
    var longDistance: Int
    var internalDistance: Int = 0
    var externalDistance = Dictionary<Int,Int>()
    
    init(d: Int) {
        nodesCount = 6
        longDistance = 3 * d
        internalDistance = 29 * d
        externalDistance[d] = 1
        externalDistance[2*d] = 2
        externalDistance[3*d] = 2
    }
    
    init(d: Int, g: Graph) {
        
        nodesCount = g.nodesCount * 4 + 2
        
        var m = Dictionary<Int,Int>()
        m[1*d] = 1
        m[2*d] = 2
        m[3*d] = 2
        
        let gm = g.externalDistance.multiply(m)
        let gg = g.externalDistance.multiply(g.externalDistance)
        let gg2 = gg.add(2*d)
        let gg3 = gg.add(3*d)
        
        let x1 = 4 * g.internalDistance + 29 * d
        let x2 = gm.map{ $0.0 * $0.1 }.reduce(0, combine: +)
        let x3 = x2 * 4
        let x4 = gg3.map{ $0.0 * $0.1 }.reduce(0, combine: +)
        let x5 = x4 * 4
        let x6 = gg2.map{ $0.0 * $0.1 }.reduce(0, combine: +)
        let x7 = x6 * 2
        
        internalDistance += x1
        internalDistance += x3
        internalDistance += x5
        internalDistance += x7
        
        let d1 = g.externalDistance
        let d2 = m.add(g.longDistance)
        let d3 = g.externalDistance.add(g.longDistance + 3 * d).multiply(2)
        let d4 = g.externalDistance.add(g.longDistance + 2 * d)
        
        externalDistance.add(d1)
        externalDistance.add(d2)
        externalDistance.add(d3)
        externalDistance.add(d4)
        
        longDistance = 2 * g.longDistance + 3 * d
        
    }
    
    var description: String {
        var distance = ""
        externalDistance.sort{ $0.0 < $1.0 }.forEach{ distance += "\($0.0) => \($0.1)\n" }
        return "nodes: \(nodesCount)\ntotal: \(internalDistance)\nlongDistance:\(longDistance)\nexternal:\n\(distance)"
    }
    
}

class OldGraph {
    
    let count: Int
    var matrix: [Int]
    
    init(count: Int) {
        self.count = count
        matrix = Array(count: count * count, repeatedValue: 0)
    }
    
    func f(n1: Int, _ n2: Int) -> Int {
        var queue = [Int]()
        var visited = [Int:Int]()
        queue.append(n1)
        visited[n1] = 1
        stop:while !queue.isEmpty {
            let n = queue.removeFirst()
            for i in 1...count {
                let d = distance(n, i)
                if d != 0 && visited[i] == nil {
                    visited[i] = visited[n]! + d
                    queue.append(i)
                }
            }
        }
        let d = visited[n2]! - 1
        print("\(n1) \(n2) \(d)")
        return d
    }
    
    func allDistances() -> Int {
        var d = 0
        for n1 in 1...count {
            d += distance(n1)
        }
        return d
    }
    
    func distance(n1: Int) -> Int {
        var t = 0
        guard n1 != count else { return 0 }
        for n2 in n1+1...count {
            t += f(n1,n2)
        }
        return t
    }
    
    func distance(n1: Int, _ n2: Int) -> Int {
        return matrix[index(n1,n2)]
    }
    
    func link(n1: Int, _ n2: Int, distance: Int) {
        matrix[index(n1,n2)] = distance
        matrix[index(n2,n1)] = distance
    }
    
    @inline(__always) func index(x: Int, _ y: Int) -> Int {
        return (x - 1) * count + (y - 1)
    }
    
}

func addCone(g: OldGraph, d: Int) {
    g.link(1 + d, 2 + d, distance: 2)
    g.link(2 + d, 3 + d, distance: 2)
    g.link(2 + d, 5 + d, distance: 2)
    g.link(4 + d, 5 + d, distance: 2)
    g.link(5 + d, 6 + d, distance: 2)
}

//let g = OldGraph(count: 26)
//addCone(g, d: 0)
//addCone(g, d: 6)
//addCone(g, d: 12)
//addCone(g, d: 18)
//g.link(6, 25, distance: 1)
//g.link(25, 10, distance: 1)
//g.link(25, 26, distance: 1)
//g.link(15, 26, distance: 1)
//g.link(19, 26, distance: 1)
//print(g.allDistances())

let g1 = Graph(d: 2)
print(g1)
let g2 = Graph(d: 1, g: g1)
print(g2)
let g3 = Graph(d: 1, g: g2)
print(g3)
let g4 = Graph(d: 1, g: g3)
print(g4)
//let g5 = Graph(d: 1, g: g4)
//print(g5)
//let g6 = Graph(d: 1, g: g5)
//print(g6)


