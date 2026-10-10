package com.anafitlab.backend.common;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Keeps the API contract and Swagger UI public. Interim: the full SecurityConfig (JWT, roles)
 * arrives in a later task and should absorb these matchers.
 */
@Configuration(proxyBeanMethods = false)
class ContractDocsSecurityConfig {

	@Bean
	@Order(Ordered.HIGHEST_PRECEDENCE)
	SecurityFilterChain contractDocsFilterChain(HttpSecurity http) throws Exception {
		http.securityMatcher("/openapi.yaml", "/swagger-ui.html", "/swagger-ui/**", "/v3/api-docs/**")
				.authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
				.csrf(csrf -> csrf.disable())
				.cors(Customizer.withDefaults());
		return http.build();
	}

}
