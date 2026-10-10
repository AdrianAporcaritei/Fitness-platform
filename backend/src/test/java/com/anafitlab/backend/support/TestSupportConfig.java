package com.anafitlab.backend.support;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Import;

@TestConfiguration(proxyBeanMethods = false)
@Import(TestFixtures.class)
public class TestSupportConfig {

}
