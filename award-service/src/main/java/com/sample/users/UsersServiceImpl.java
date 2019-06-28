package com.sample.users;

import com.sample.users.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.client.RestTemplate;

public class UsersServiceImpl implements UsersService {

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    @Qualifier("UsersServiceUrl")
    private String usersServiceUrl;


    @Override
    public User getUser(long id) {
        User user = restTemplate.getForObject(usersServiceUrl + "/users/" + id, User.class);
        return user;
    }
}
