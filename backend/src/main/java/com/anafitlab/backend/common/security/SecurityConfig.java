package com.anafitlab.backend.common.security;

import java.util.ArrayList;
import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.oauth2.server.resource.web.BearerTokenResolver;
import org.springframework.security.oauth2.server.resource.web.DefaultBearerTokenResolver;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.servlet.util.matcher.PathPatternRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.anafitlab.backend.common.AppProperties;

/** Stateless JWT resource server; role and public-route rules live here (data rules are in the services). */
@Configuration(proxyBeanMethods = false)
class SecurityConfig {

	private static final String API = "/api/v1";

	/** Routes that need no token. Also exempt from bearer parsing, so a stale token cannot break them. */
	private static final RequestMatcher PUBLIC = new OrRequestMatcher(
			post(API + "/auth/register/**", API + "/auth/login", API + "/auth/refresh", API + "/auth/logout",
					API + "/auth/verify-email", API + "/auth/password-reset/**"),
			path(HttpMethod.GET, API + "/invites/*"),
			path(null, "/openapi.yaml", "/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/swagger-config",
					"/actuator/health"));

	private static RequestMatcher post(String... patterns) {
		return path(HttpMethod.POST, patterns);
	}

	private static RequestMatcher path(HttpMethod method, String... patterns) {
		List<RequestMatcher> matchers = new ArrayList<>();
		for (String pattern : patterns) {
			matchers.add(PathPatternRequestMatcher.withDefaults().matcher(method, pattern));
		}
		return new OrRequestMatcher(matchers);
	}

	@Bean
	SecurityFilterChain securityFilterChain(HttpSecurity http, ProblemAuthenticationEntryPoint entryPoint,
			ProblemAccessDeniedHandler accessDeniedHandler) throws Exception {
		http
				.csrf(AbstractHttpConfigurer::disable)
				.cors(Customizer.withDefaults())
				.sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.authorizeHttpRequests(auth -> auth
						.requestMatchers(PUBLIC).permitAll()
						.requestMatchers(API + "/coach/**").hasRole("COACH")
						.requestMatchers(API + "/me/coach-link", API + "/me/coach/**").hasRole("CLIENT")
						.requestMatchers(API + "/admin/**").hasRole("ADMIN")
						.anyRequest().authenticated())
				.exceptionHandling(e -> e.authenticationEntryPoint(entryPoint).accessDeniedHandler(accessDeniedHandler))
				.oauth2ResourceServer(o -> o.authenticationEntryPoint(entryPoint)
						.bearerTokenResolver(bearerTokenResolver())
						.accessDeniedHandler(accessDeniedHandler)
						.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())));
		return http.build();
	}

	private static BearerTokenResolver bearerTokenResolver() {
		DefaultBearerTokenResolver delegate = new DefaultBearerTokenResolver();
		return request -> PUBLIC.matches(request) ? null : delegate.resolve(request);
	}

	/** The {@code role} claim becomes the {@code ROLE_<role>} authority. */
	private static JwtAuthenticationConverter jwtAuthenticationConverter() {
		JwtGrantedAuthoritiesConverter authorities = new JwtGrantedAuthoritiesConverter();
		authorities.setAuthoritiesClaimName("role");
		authorities.setAuthorityPrefix("ROLE_");
		JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
		converter.setJwtGrantedAuthoritiesConverter(authorities);
		return converter;
	}

	@Bean
	CorsConfigurationSource corsConfigurationSource(AppProperties properties) {
		CorsConfiguration cors = new CorsConfiguration();
		cors.setAllowedOrigins(properties.corsAllowedOrigins());
		cors.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
		cors.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept", "Accept-Language"));
		cors.setExposedHeaders(List.of("Retry-After", "WWW-Authenticate"));
		cors.setMaxAge(3600L);
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", cors);
		return source;
	}

}
