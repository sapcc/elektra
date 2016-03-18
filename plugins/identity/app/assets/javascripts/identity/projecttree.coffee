# class ProjectTree
#   @findExpandibleNodess = () ->
#     $expandibleTree.treeview('search', [ $('#input-expand-node').val(), { ignoreCase: false, exactMatch: false } ]);
#   };
#   var expandibleNodes = findExpandibleNodess();
#
#   // Expand/collapse/toggle nodes
#   $('#input-expand-node').on('keyup', function (e) {
#     expandibleNodes = findExpandibleNodess();
#     $('.expand-node').prop('disabled', !(expandibleNodes.length >= 1));
#   });
#
#   $('#btn-expand-node.expand-node').on('click', function (e) {
#     var levels = $('#select-expand-node-levels').val();
#     $expandibleTree.treeview('expandNode', [ expandibleNodes, { levels: levels, silent: $('#chk-expand-silent').is(':checked') }]);
#   });
#
#   $('#btn-collapse-node.expand-node').on('click', function (e) {
#     $expandibleTree.treeview('collapseNode', [ expandibleNodes, { silent: $('#chk-expand-silent').is(':checked') }]);
#   });
#
# identity.projecttree = ProjectTree
#
#
#
# $(document).ready () ->
#
#   console.log 'ready'
#
#     # var $expandibleTree = $('#projecttree').treeview({
#     #   enableLinks: true,
#     #   levels: 2,
#     #   showBorder: false,
#     #   showTags: true,
#     #   color: '#337ab7',
#     #   collapseIcon: 'fa fa-minus',
#     #   expandIcon: 'fa fa-plus',
#     #   data: [#{projects_tree.to_json}],
#     #
#     #   onNodeCollapsed: function(event, node) {
#     #     //$('#expandible-output').prepend('<p>' + node.text + ' was collapsed</p>');
#     #   },
#     #   onNodeExpanded: function (event, node) {
#     #     //$('#expandible-output').prepend('<p>' + node.text + ' was expanded</p>');
#     #   }
#     # });
#     #
#     # var findExpandibleNodess = function() {
#     #   return $expandibleTree.treeview('search', [ $('#input-expand-node').val(), { ignoreCase: false, exactMatch: false } ]);
#     # };
#     # var expandibleNodes = findExpandibleNodess();
#     #
#     # // Expand/collapse/toggle nodes
#     # $('#input-expand-node').on('keyup', function (e) {
#     #   expandibleNodes = findExpandibleNodess();
#     #   $('.expand-node').prop('disabled', !(expandibleNodes.length >= 1));
#     # });
#     #
#     # $('#btn-expand-node.expand-node').on('click', function (e) {
#     #   var levels = $('#select-expand-node-levels').val();
#     #   $expandibleTree.treeview('expandNode', [ expandibleNodes, { levels: levels, silent: $('#chk-expand-silent').is(':checked') }]);
#     # });
#     #
#     # $('#btn-collapse-node.expand-node').on('click', function (e) {
#     #   $expandibleTree.treeview('collapseNode', [ expandibleNodes, { silent: $('#chk-expand-silent').is(':checked') }]);
#     # });