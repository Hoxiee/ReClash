package rcx

func rcxUniqueProbeNodes(nodes []rcxProbeNode, preferred string) []rcxProbeNode {
	selected := make(map[string]int, len(nodes))
	result := make([]rcxProbeNode, 0, len(nodes))
	for _, node := range nodes {
		key := node.Key
		if key == "" {
			key = node.Name
		}
		if at, ok := selected[key]; ok {
			if node.Name == preferred {
				result[at] = node
			}
			continue
		}
		selected[key] = len(result)
		result = append(result, node)
	}
	return result
}
