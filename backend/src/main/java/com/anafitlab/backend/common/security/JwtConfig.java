package com.anafitlab.backend.common.security;

import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtTimestampValidator;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

import com.nimbusds.jose.jwk.source.ImmutableSecret;

/** HS256 access-token encoder and decoder; the secret must be at least 256 bits (32 UTF-8 bytes). */
@Configuration(proxyBeanMethods = false)
public class JwtConfig {

	static final int MIN_SECRET_BYTES = 32;

	@Bean
	JwtEncoder jwtEncoder(JwtProperties properties) {
		return new NimbusJwtEncoder(new ImmutableSecret<>(secretKey(properties)));
	}

	@Bean
	JwtDecoder jwtDecoder(JwtProperties properties, Clock clock) {
		NimbusJwtDecoder decoder = NimbusJwtDecoder.withSecretKey(secretKey(properties))
				.macAlgorithm(MacAlgorithm.HS256).build();
		JwtTimestampValidator timestamps = new JwtTimestampValidator(Duration.ZERO);
		timestamps.setClock(clock);
		timestamps.setAllowEmptyExpiryClaim(false);
		decoder.setJwtValidator(new DelegatingOAuth2TokenValidator<>(timestamps));
		return decoder;
	}

	private static SecretKey secretKey(JwtProperties properties) {
		String secret = properties.secret();
		if (secret == null) {
			throw new IllegalStateException("app.jwt.secret is required");
		}
		byte[] bytes = secret.getBytes(StandardCharsets.UTF_8);
		if (bytes.length < MIN_SECRET_BYTES) {
			throw new IllegalStateException(
					"app.jwt.secret must be at least " + MIN_SECRET_BYTES + " bytes (256 bits), got " + bytes.length);
		}
		return new SecretKeySpec(bytes, "HmacSHA256");
	}

}
