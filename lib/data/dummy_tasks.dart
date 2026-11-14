import '../models/task.dart';

final List<Task> dummyTasks = [
  Task(
    id: '1',
    title: 'Data Structures Assignment',
    description: 'Implement Quick Sort and explain the partition process.',
    priority: 'Urgent - Tomorrow',
    label: 'Data Structures',
    deadline: '3 Oct 2026 • 23:59',
    completed: false,
  ),
  Task(
    id: '2',
    title: 'Mobile Prototype',
    description: 'Complete the flow and usability testing for the prototype.',
    priority: 'Moderate Deadline',
    label: 'Project',
    deadline: '5 Oct 2026 • 20:00',
    completed: false,
  ),
  Task(
    id: '3',
    title: 'Read Chapter 4',
    description: 'Write down important points about memory management.',
    priority: 'Safe',
    label: 'Operating Systems',
    deadline: '10 Oct 2026 • 17:00',
    completed: false,
  ),
  Task(
    id: '4',
    title: 'Matrix Exercises',
    description: 'Complete the matrix exercises and submit your answers.',
    priority: 'Completed',
    label: 'Calculus',
    deadline: '1 Oct 2026 • 18:00',
    completed: true,
  ),
];
