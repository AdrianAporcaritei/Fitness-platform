package com.anafitlab.backend.common.error;

import org.hibernate.exception.ConstraintViolationException;

/** Maps database constraint violations to the business errors they stand for. */
public final class ConstraintViolations {

	private ConstraintViolations() {
	}

	/** Whether the failure, or any of its causes, is a violation of the named constraint. */
	public static boolean violates(Throwable e, String constraint) {
		for (Throwable t = e; t != null; t = t.getCause()) {
			if (t instanceof ConstraintViolationException cve && constraint.equals(cve.getConstraintName())) {
				return true;
			}
		}
		return false;
	}

}
