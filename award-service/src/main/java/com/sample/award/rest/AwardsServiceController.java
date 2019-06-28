package com.sample.award.rest;

import com.sample.award.model.Award;
import com.sample.award.service.AwardService;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Collection;

@Controller
@RequestMapping(value = "/awards")
public class AwardsServiceController {

    private static final Logger log = LoggerFactory.getLogger(AwardsServiceController.class);

    @Autowired
    AwardService awardService;


    @RequestMapping(method = RequestMethod.GET)
    @ResponseBody
    @ApiOperation(value = "Get all Awards", response = Award.class)
    @ApiResponses({
            @ApiResponse(code = 401, message = "authorization information is missing or invalid"),
            @ApiResponse(code = 500, message = "internal server error")
    })
    public Collection<Award> getAllAwards() {
        log.info("Attempt to get all Awards");
        return awardService.getAllAwards();
    }

    @RequestMapping(method = RequestMethod.POST)
    @ResponseBody
    @ApiOperation(value = "Create new Award", response = Award.class)
    @ApiResponses({
            @ApiResponse(code = 401, message = "authorization information is missing or invalid"),
            @ApiResponse(code = 500, message = "internal server error")
    })
    public Award createAward(@ApiParam(value = "New award", required = true)
                             @RequestBody Award award) {
        log.info("Attempt to create new Award:" + award);
        long id = awardService.createAward(award);
        return new Award(id,
                award.getNominatorId(),
                award.getNomineeId(),
                award.getText(),
                award.getAmount());
    }
}
