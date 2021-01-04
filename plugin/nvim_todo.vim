
fun! ShowTodoList()
    lua require("nvim_todo").show()
endfun

com! TodoList call ShowTodoList()
