package com.sample.award;

import com.sample.award.dao.AwardsDao;
import com.sample.award.dao.AwardsDaoInMemoryImpl;
import com.sample.award.service.AwardService;
import com.sample.award.service.AwardServiceImpl;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class AwardServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(AwardServiceApplication.class, args);
	}

	@Bean
	public AwardsDao awardsDao() {
		return new AwardsDaoInMemoryImpl();
	}

	@Bean
	public AwardService awardsService() {
		return new AwardServiceImpl();
	}

}
