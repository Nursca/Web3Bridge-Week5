// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Todo {

    struct Task {
        uint8 id;
        string title;
        bool isComplete;
        uint timeCompleted;
    }

    //state variables
    Task[] public tasks; // an array to contain all tasks that will be created
    uint8 todo_id; // an id for each task as an identifier 

    function createTask(string memory _title) external {
        uint8 id = todo_id + 1;
        // Task memory task = Task(id, _title, false, 0);
        // task id = 1
        Task memory task = Task({id: id, title: _title, isComplete: false, timeCompleted: 0});
        tasks.push(task);
        todo_id = todo_id + 1;
        // this helps us to increment the id for subsequent calls or tasks
        // that would be created.
    }

    function getAllTasks() external view returns (Task[] memory) {
        return tasks;
    }

    function markComplete(uint8 _id) external {
        for (uint8 i; i < tasks.length; i++) {
            if (tasks[i].id == _id) {
                tasks[i].isComplete = true;
                tasks[i].timeCompleted = block.timestamp;
            }
        }
    }

    function deleteTask(uint8 _id) external{
        for (uint8 i; i < tasks.length; i++) {
            if (tasks[i].id == _id) {
                tasks[i] = tasks [tasks.length -1];
                tasks.pop();
            }
        }
    }

    function updateTask(uint8 _id, string memory _title) external {
        for (uint8 i;i < tasks.length; i++) {
            if (tasks[i].id == _id) {
                tasks[i].title = _title;
            }
        }
    }
}