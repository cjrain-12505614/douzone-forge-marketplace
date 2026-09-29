package klago.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 로컬 풀스택 개발 전용 CORS 허용 (브라우저 :3000 → 로컬 BE).
 *
 * <p>Amaranth 10 모듈 앱에는 Spring Security 가 없어 Spring MVC 의 DefaultCorsProcessor 가
 * 교차 출처 OPTIONS 프리플라이트를 거절(403)한다. 개발 서버 앞단(nginx/k8s)이 붙여 주던
 * CORS 헤더가 로컬 단독 기동엔 없으므로 직접 보강한다.
 *
 * <p>게이트: {@code Klago.localCors=true} 가 있을 때만 등록된다. 운영/개발 서버의
 * application.yml 에는 이 키가 없으므로 운영에는 영향이 없다(로컬 클론 전용).
 *
 * <p>모듈 무관 동일 — dz-module-devenv 스킬이 모든 모듈 클론의
 * src/main/java/klago/config/ 에 그대로 복사한다.
 */
@Configuration
@ConditionalOnProperty(name = "Klago.localCors", havingValue = "true")
public class LocalDevCorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("http://localhost:3000", "http://127.0.0.1:3000")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD")
                .allowedHeaders("*")
                .exposedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
