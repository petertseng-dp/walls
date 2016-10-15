class Graph
  class Node
    getter :id

    @out_edges = {} of Node => Int32 | Float64
    @flow = {} of Node => Int32
    @edges_locked = false

    def initialize(@id : Symbol | Tuple(Int32, Int32, Symbol))
    end

    def has_residual?(target : Node, min : Int32) : Bool
      (@out_edges[target]? || 0) > min
    end

    def add_edge(target : Node, capacity : Int32 | Float64)
      raise "Can't add more edges to #{@id}, flow has been set." if @edges_locked
      raise "#{@id} already has edge to #{target.id}" if @out_edges.has_key?(target)
      @out_edges[target] = capacity
      @flow[target] = 0
      target.flow[self] = 0
    end

    protected def add_flow(target : Node, capacity : Int32)
      @edges_locked = true
      raise "#{@id} has no flow to #{target.id}" unless @flow.has_key?(target)
      @flow[target] += capacity
    end

    protected getter :out_edges
    protected getter :flow
  end

  @source = Node.new(:source)
  @sink = Node.new(:sink)

  def node_pair(coords : Tuple(Int32, Int32), capacity : Int32 | Float64, from_source = false, to_sink = false) : Tuple(Node, Node)
    y, x = coords
    in_node = Node.new({y, x, :in})
    out_node = Node.new({y, x, :out})

    in_node.add_edge(out_node, capacity)
    @source.add_edge(in_node, Float64::INFINITY) if from_source
    out_node.add_edge(@sink, Float64::INFINITY) if to_sink

    {in_node, out_node}
  end

  def reachable_nodes : Set(Node)
    visited = Set.new([@source])
    frontier = @source.out_edges.keys
    until frontier.empty?
      current = frontier.shift
      visited.add(current)
      frontier.concat(current.flow.select { |k, v|
        !visited.includes?(k) && current.has_residual?(k, v)
      }.map { |k, v| k })
    end
    visited
  end

  def edmonds_karp : UInt32?
    max_flow = 0_u32
    while (path = bfs)
      capacity = path.each_cons(2).map { |(u, v)| (u.out_edges[v]? || 0) - u.flow[v] }.min
      return nil if capacity == Float64::INFINITY
      max_flow += capacity.to_u32
      path.each_cons(2) { |(u, v)|
        u.add_flow(v, capacity.to_i32)
        v.add_flow(u, -capacity.to_i32)
      }
    end
    max_flow
  end

  private def bfs : Array(Node)?
    parent = {@source => @source}.merge(@source.out_edges.keys.map { |k| {k, @source} }.to_h)
    frontier = @source.out_edges.keys
    until frontier.empty?
      current = frontier.shift
      if current == @sink
        path = [@sink]
        next_node = parent[@sink]
        until next_node == @source
          path << next_node
          next_node = parent[next_node]
        end
        return [@source] + path.reverse
      end
      current.flow.select { |k, v|
        !parent.has_key?(k) && current.has_residual?(k, v)
      }.each { |k, v|
        parent[k] = current
        frontier << k
      }
    end
    nil
  end
end
