
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

var g = Graph(d: 2)
print(g)
for _ in 1..<2 {
    g = Graph(d: 1, g: g)
    print(g)
}
