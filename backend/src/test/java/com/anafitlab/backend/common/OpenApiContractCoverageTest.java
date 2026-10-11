package com.anafitlab.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.util.ClassUtils;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;
import org.yaml.snakeyaml.Yaml;

import com.anafitlab.backend.TestcontainersConfiguration;

/** Every API endpoint in the main sources must be in docs/api/openapi.yaml and vice versa. */
@Import(TestcontainersConfiguration.class)
@SpringBootTest
@ActiveProfiles("test")
class OpenApiContractCoverageTest {

	private static final String BASE_PACKAGE = "com.anafitlab.backend";

	private static final String API_PREFIX = "/api/v1";

	private static final Set<String> HTTP_METHODS = Set.of("get", "put", "post", "delete", "patch", "head", "options");

	@Autowired
	@Qualifier("requestMappingHandlerMapping")
	RequestMappingHandlerMapping handlerMapping;

	@Test
	void everyEndpointIsInContract() throws IOException {
		Set<String> inCode = endpointsInCode();
		Set<String> inContract = endpointsInContract();

		Set<String> missingInContract = new TreeSet<>(inCode);
		missingInContract.removeAll(inContract);
		Set<String> missingInCode = new TreeSet<>(inContract);
		missingInCode.removeAll(inCode);

		assertThat(inCode).as("sanity: controllers were found").isNotEmpty();
		assertThat(missingInContract).as("implemented but missing in openapi.yaml").isEmpty();
		assertThat(missingInCode).as("in openapi.yaml but not implemented").isEmpty();
	}

	private Set<String> endpointsInCode() {
		Set<String> result = new TreeSet<>();
		for (Map.Entry<RequestMappingInfo, HandlerMethod> entry : handlerMapping.getHandlerMethods().entrySet()) {
			Class<?> type = ClassUtils.getUserClass(entry.getValue().getBeanType());
			// Own production controllers only: excludes springdoc/actuator (other packages) and test-only
			// controllers (loaded from target/test-classes, not target/classes).
			if (!type.getPackageName().startsWith(BASE_PACKAGE) || isFromTestClasses(type)) {
				continue;
			}
			RequestMappingInfo info = entry.getKey();
			Set<String> patterns = info.getPathPatternsCondition().getPatternValues();
			Set<?> methods = info.getMethodsCondition().getMethods();
			assertThat(methods).as("%s must declare an explicit HTTP method", entry.getValue()).isNotEmpty();
			for (String pattern : patterns) {
				String path = pattern.startsWith(API_PREFIX) ? pattern.substring(API_PREFIX.length()) : pattern;
				for (Object method : methods) {
					result.add(method.toString() + " " + normalize(path));
				}
			}
		}
		return result;
	}

	private static boolean isFromTestClasses(Class<?> type) {
		var source = type.getProtectionDomain().getCodeSource();
		return source != null && source.getLocation().getPath().contains("/test-classes");
	}

	@SuppressWarnings("unchecked")
	private Set<String> endpointsInContract() throws IOException {
		Path file = Path.of("..", "docs", "api", "openapi.yaml");
		Map<String, Object> root;
		try (InputStream in = Files.newInputStream(file)) {
			root = new Yaml().load(in);
		}
		Set<String> result = new TreeSet<>();
		Map<String, Object> paths = (Map<String, Object>) root.get("paths");
		paths.forEach((path, item) -> ((Map<String, Object>) item).keySet().stream()
				.filter(HTTP_METHODS::contains)
				.forEach(method -> result.add(method.toUpperCase() + " " + normalize(path))));
		return result;
	}

	private static String normalize(String path) {
		return path.replaceAll("\\{[^}/]*}", "{}");
	}

}
