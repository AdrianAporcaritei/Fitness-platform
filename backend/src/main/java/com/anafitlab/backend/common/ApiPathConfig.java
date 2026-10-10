package com.anafitlab.backend.common;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.method.HandlerTypePredicate;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** Serves every {@code @RestController} under {@code com.anafitlab.backend} under {@code /api/v1}. */
@Configuration(proxyBeanMethods = false)
class ApiPathConfig implements WebMvcConfigurer {

	static final String API_PREFIX = "/api/v1";

	private static final String BASE_PACKAGE = "com.anafitlab.backend";

	@Override
	public void configurePathMatch(PathMatchConfigurer configurer) {
		// Own controllers only (HandlerTypePredicate ORs its criteria), so springdoc's stay at their default paths.
		HandlerTypePredicate restControllers = HandlerTypePredicate.forAnnotation(RestController.class);
		configurer.addPathPrefix(API_PREFIX,
				type -> type.getPackageName().startsWith(BASE_PACKAGE) && restControllers.test(type));
	}

}
