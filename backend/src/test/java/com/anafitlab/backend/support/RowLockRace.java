package com.anafitlab.backend.support;

import static org.assertj.core.api.Assertions.fail;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import javax.sql.DataSource;

import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Reproduces a write race deterministically: a separate transaction locks a row, the contender starts and must
 * block on that lock, then the locking transaction applies a concurrent change and commits.
 */
public final class RowLockRace {

	private RowLockRace() {
	}

	/**
	 * @param lockSql SELECT ... FOR UPDATE taking the row lock
	 * @param concurrentChangeSql the change committed while the contender waits
	 * @return what the contender threw, or null if it succeeded
	 */
	public static Throwable run(DataSource dataSource, String lockSql, String concurrentChangeSql, Object id,
			Runnable contender) throws Exception {
		JdbcTemplate monitor = new JdbcTemplate(dataSource);
		ExecutorService pool = Executors.newSingleThreadExecutor();
		try (Connection holder = dataSource.getConnection()) {
			holder.setAutoCommit(false);
			execute(holder, lockSql, id);
			Future<?> result = pool.submit(contender);
			awaitBlockedOnLock(monitor, result);
			execute(holder, concurrentChangeSql, id);
			holder.commit();
			try {
				result.get(30, TimeUnit.SECONDS);
				return null;
			}
			catch (ExecutionException e) {
				return e.getCause();
			}
		}
		finally {
			pool.shutdownNow();
		}
	}

	private static void execute(Connection connection, String sql, Object id) throws Exception {
		try (PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setObject(1, id);
			statement.execute();
		}
	}

	private static void awaitBlockedOnLock(JdbcTemplate monitor, Future<?> contender) throws Exception {
		long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(10);
		while (System.nanoTime() < deadline) {
			Integer waiting = monitor.queryForObject(
					"SELECT count(*) FROM pg_stat_activity WHERE datname = current_database() AND wait_event_type = 'Lock'",
					Integer.class);
			if (waiting != null && waiting > 0) {
				return;
			}
			if (contender.isDone()) {
				fail("contender finished without waiting for the row lock");
			}
			Thread.sleep(20);
		}
		fail("contender never blocked on the row lock");
	}

}
