require "./graph"

module Walls
  def self.solve(grid : Array(String)) : Tuple(UInt32?, Array(String))
    graph = Graph.new

    nodes = grid.map_with_index { |row, y|
      row.each_char.map_with_index { |cell, x|
        case cell
        when '#'
          nil
        when '+'
          graph.node_pair({y, x}, Float64::INFINITY)
        when '-'
          graph.node_pair({y, x}, 1)
        when 'o'
          graph.node_pair({y, x}, Float64::INFINITY, to_sink: true)
        when '*'
          # If the source is the nest, walls tend to be closer to the nest.
          # The opposite is true if the source is the bunker.
          graph.node_pair({y, x}, Float64::INFINITY, from_source: true)
        else
          raise "Unknown character #{cell} at #{y}, #{x}"
        end
      }
    }

    nodes.each_cons(2) { |(row1, row2)|
      row1.zip(row2).each { |pair1, pair2|
        next unless pair1 && pair2
        in1, out1 = pair1
        in2, out2 = pair2
        out1.add_edge(in2, Float64::INFINITY)
        out2.add_edge(in1, Float64::INFINITY)
      }
    }

    nodes.each { |row|
      row.each_cons(2) { |(pair1, pair2)|
        next unless pair1 && pair2
        in1, out1 = pair1
        in2, out2 = pair2
        out1.add_edge(in2, Float64::INFINITY)
        out2.add_edge(in1, Float64::INFINITY)
      }
    }

    walls_needed = graph.edmonds_karp
    reachable = graph.reachable_nodes

    {walls_needed, grid.map_with_index { |row, y|
      (0...row.size).map { |x|
        pair = nodes[y][x]
        pair && (reachable.includes?(pair[0]) && !reachable.includes?(pair[1])) ? '@' : grid[y][x]
      }.join
    }}
  end
end
