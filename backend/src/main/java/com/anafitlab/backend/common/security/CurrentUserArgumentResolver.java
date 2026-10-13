package com.anafitlab.backend.common.security;

import java.util.List;
import java.util.UUID;

import org.springframework.core.MethodParameter;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.anafitlab.backend.auth.entity.Role;

/** Lets controllers declare a {@link CurrentUser} parameter. */
@Component
class CurrentUserArgumentResolver implements HandlerMethodArgumentResolver, WebMvcConfigurer {

	@Override
	public boolean supportsParameter(MethodParameter parameter) {
		return CurrentUser.class.equals(parameter.getParameterType());
	}

	@Override
	public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
			NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		if (!(authentication instanceof JwtAuthenticationToken token)) {
			throw new BadCredentialsException("No access token");
		}
		Jwt jwt = token.getToken();
		try {
			return new CurrentUser(UUID.fromString(jwt.getSubject()), Role.valueOf(jwt.getClaimAsString("role")));
		}
		catch (IllegalArgumentException | NullPointerException e) {
			throw new BadCredentialsException("Malformed access token claims", e);
		}
	}

	@Override
	public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
		resolvers.add(this);
	}

}
