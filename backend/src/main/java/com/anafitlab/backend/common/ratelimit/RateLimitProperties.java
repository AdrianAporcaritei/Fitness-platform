package com.anafitlab.backend.common.ratelimit;

import java.time.Duration;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Rate limits (spec 5.11) under {@code app.rate-limit.*}. Each rule may override {@code max} and/or
 * {@code window}; anything left out keeps the default below.
 */
@ConfigurationProperties("app.rate-limit")
public record RateLimitProperties(Rule loginEmail, Rule loginIp, Rule signupIp, Rule resetEmail, Rule resetIp,
		Rule verifyResend, Rule inviteIp) {

	public RateLimitProperties {
		loginEmail = Rule.orDefault(loginEmail, 5, Duration.ofMinutes(15));
		loginIp = Rule.orDefault(loginIp, 20, Duration.ofMinutes(15));
		signupIp = Rule.orDefault(signupIp, 10, Duration.ofHours(1));
		resetEmail = Rule.orDefault(resetEmail, 3, Duration.ofHours(1));
		resetIp = Rule.orDefault(resetIp, 10, Duration.ofHours(1));
		verifyResend = Rule.orDefault(verifyResend, 3, Duration.ofHours(1));
		inviteIp = Rule.orDefault(inviteIp, 20, Duration.ofMinutes(15));
	}

	public record Rule(Integer max, Duration window) {

		static Rule orDefault(Rule rule, int defaultMax, Duration defaultWindow) {
			if (rule == null) {
				return new Rule(defaultMax, defaultWindow);
			}
			return new Rule(rule.max() != null ? rule.max() : defaultMax,
					rule.window() != null ? rule.window() : defaultWindow);
		}

		public Limit limit() {
			return new Limit(max, window);
		}

	}

}
