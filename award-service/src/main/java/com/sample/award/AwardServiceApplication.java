package com.sample.award;

import com.sample.award.dao.AwardsDao;
import com.sample.award.dao.AwardsDaoInMemoryImpl;
import com.sample.award.service.AwardService;
import com.sample.award.service.AwardServiceImpl;
import com.sample.users.UsersService;
import com.sample.users.UsersServiceImpl;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

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

	@Bean
	public UsersService usersService() {
		return new UsersServiceImpl();
	}

	@Bean
	public RestTemplate restTemplate() {
		return new RestTemplate();
	}

	@Bean
	@Qualifier("UsersServiceUrl")
	public String usersServiceUrl() {
		return "http://localhost:8081";
	}

}
