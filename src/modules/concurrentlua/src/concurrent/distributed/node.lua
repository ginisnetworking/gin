-- Submodule for node related operations.
local _node = {}

_node.nodemonitors = {}         -- Nodes monitoring the node.

-- Returns the node's name.
function _node.node()
    return concurrent._distributed._network.nodename
end

-- Returns a table with the names of the nodes that the node is connected to.
function _node.nodes()
    local t = {}
    for k, _ in pairs(concurrent._distributed._network.connections) do
        table.insert(t, k)
    end
    return t
end

-- Returns a true if the node has been initialized or false otherwise.
function _node.isnodealive()
    return _node.node() ~= nil
end

-- Starts monitoring the specified node.
function _node.monitornode(name)
    local s = concurrent.self()
    if not _node.nodemonitors[s] then
        _node.nodemonitors[s] = {}
    end
    table.insert(_node.nodemonitors[s], name)
end

-- Stops monitoring the specified node.
function _node.demonitornode(name)
    local s = concurrent.self()
    if not _node.nodemonitors[s] then
        return
    end
    for k, v in pairs(_node.nodemonitors[s]) do
        if name == v then
            table.remove(_node.nodemonitors[s], k)
        end
    end
end

-- Notifies all the monitoring processes about the status change of a node.
function _node.notify_all(deadnode)
    for k, v in pairs(_node.nodemonitors) do
        for l, w in pairs(v) do
            if w == deadnode then
                _node.notify(k, w, 'noconnection')
            end
        end
    end
end

-- Notifies a single process about the status of a node. 
function _node.notify(dest, deadnode, reason)
    concurrent.send(dest, { signal = 'NODEDOWN', from = { dead,
        concurrent.node() }, reason = reason })
end

-- Monitoring processes should be notified when the connection with a node is
-- lost.
table.insert(concurrent._distributed._network.onfailure, _node.notify_all)

concurrent.node = _node.node
concurrent.nodes = _node.nodes
concurrent.isnodealive = _node.isnodealive
concurrent.monitornode = _node.monitornode
concurrent.demonitornode = _node.demonitornode

return _node
