package com.anafitlab.backend.common.mail;

import org.springframework.beans.factory.DisposableBean;
import org.springframework.core.task.SyncTaskExecutor;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Component;

/** Owns the email worker pool privately so it is not exposed as an Executor bean. */
@Component
public class EmailDispatcher implements DisposableBean {

	private final TaskExecutor executor;
	private final ThreadPoolTaskExecutor pool;

	public EmailDispatcher(MailProperties properties) {
		if (properties.synchronous()) {
			this.pool = null;
			this.executor = new SyncTaskExecutor();
		}
		else {
			ThreadPoolTaskExecutor p = new ThreadPoolTaskExecutor();
			p.setThreadNamePrefix("email-");
			p.setCorePoolSize(2);
			p.setMaxPoolSize(4);
			p.setQueueCapacity(200);
			p.setWaitForTasksToCompleteOnShutdown(true);
			p.setAwaitTerminationSeconds(10);
			p.initialize();
			this.pool = p;
			this.executor = p;
		}
	}

	public void dispatch(Runnable task) {
		executor.execute(task);
	}

	@Override
	public void destroy() {
		if (pool != null) {
			pool.shutdown();
		}
	}

}
