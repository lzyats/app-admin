package com.ruoyi.web.controller.system;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.SysSecurityQuestion;
import com.ruoyi.system.service.ISysSecurityQuestionService;

/**
 * 安全问题 信息操作处理
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/system/security/question")
public class SysSecurityQuestionController extends BaseController
{
    @Autowired
    private ISysSecurityQuestionService questionService;

    /**
     * 获取安全问题列表（公开接口，用于用户选择）
     */
    @GetMapping("/list")
    public AjaxResult list()
    {
        List<SysSecurityQuestion> list = questionService.selectQuestionAll();
        return success(list);
    }

    /**
     * 根据问题编号获取详细信息
     */
    @GetMapping(value = "/{questionId}")
    public AjaxResult getInfo(@PathVariable Long questionId)
    {
        return success(questionService.selectQuestionById(questionId));
    }

    /**
     * 新增安全问题（管理员）
     */
    @PostMapping
    @PreAuthorize("@ss.hasPermi('system:question:add')")
    @Log(title = "安全问题", businessType = BusinessType.INSERT)
    public AjaxResult add(@RequestBody SysSecurityQuestion question)
    {
        return toAjax(questionService.insertQuestion(question));
    }

    /**
     * 修改安全问题（管理员）
     */
    @PutMapping("/{questionId}")
    @PreAuthorize("@ss.hasPermi('system:question:edit')")
    @Log(title = "安全问题", businessType = BusinessType.UPDATE)
    public AjaxResult edit(@PathVariable Long questionId, @RequestBody SysSecurityQuestion question)
    {
        question.setQuestionId(questionId);
        return toAjax(questionService.updateQuestion(question));
    }

    /**
     * 删除安全问题（管理员）
     */
    @DeleteMapping("/{questionIds}")
    @PreAuthorize("@ss.hasPermi('system:question:remove')")
    @Log(title = "安全问题", businessType = BusinessType.DELETE)
    public AjaxResult remove(@PathVariable Long[] questionIds)
    {
        return toAjax(questionService.deleteQuestionByIds(questionIds));
    }
}