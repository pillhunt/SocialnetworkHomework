﻿
using Microsoft.VisualStudio.Threading;
using Newtonsoft.Json;
using System.Collections.Concurrent;
using System.Net;
using System.Threading.Tasks;

namespace SocialnetworkHomework.workers
{
    internal sealed class RequestManager : BackgroundService
    {
        private CancellationToken cancellationToken;

        private readonly SemaphoreSlim taskQueueSemaphore;
        private readonly ConcurrentQueue<Task<IResult>> taskQueue;

        public RequestManager(SemaphoreSlim taskQueueSemaphore, ConcurrentQueue<Task<IResult>> taskQueue) 
        {
            this.taskQueue = taskQueue;
            this.taskQueueSemaphore = taskQueueSemaphore;
        }

        protected override async Task ExecuteAsync(CancellationToken cancellationToken)
        {
            Task<IResult> processedTask;

            this.cancellationToken = cancellationToken;
            AsyncManualResetEvent executorFinishSignal = new AsyncManualResetEvent();
            var tasksWaitingList = new List<Task<IResult>>();

            while (!cancellationToken.IsCancellationRequested || !taskQueue.IsEmpty)
            {
                try
                {
                    await taskQueueSemaphore.WaitAsync(cancellationToken);
                }
                catch (OperationCanceledException)
                {
                    if (taskQueue.IsEmpty)
                        break;
                }

                if (!taskQueue.TryDequeue(out processedTask))
                {
                    continue;
                }

                tasksWaitingList.Add(processedTask);
                
                while (tasksWaitingList.Count > 0)
                {
                    var isFirstTask = true;
                    foreach (var taskInWaitingList in tasksWaitingList.ToList())
                    {
                        if (isFirstTask)
                        {
                            isFirstTask = false;
                            executorFinishSignal.Reset();
                        }

                        _ = Task.Run(async () => await taskInWaitingList);
                        tasksWaitingList.Remove(taskInWaitingList);
                    }

                    if (taskQueueSemaphore.CurrentCount > 0 || tasksWaitingList.Count == 0)
                        break;

                    Task taskQueueWaitingTask;
                    await Task.WhenAny(taskQueueWaitingTask = taskQueueSemaphore.WaitAsync(), executorFinishSignal.WaitAsync());
                    taskQueueSemaphore.Release();
                    await taskQueueWaitingTask;
                    if (taskQueueSemaphore.CurrentCount > 0)
                        break;
                }
            }

            // Task.WaitAll(tasksWaitingList.ToArray(), cancellationToken);
        }      
    }
}